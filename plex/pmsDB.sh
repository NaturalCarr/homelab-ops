#!/bin/bash

######################################################################################################################
# PLEASE MAKE SURE THESE 3 VARIABLES ARE CORRECT FOR YOUR SERVER
######################################################################################################################
appdata_directory="/mnt/user/addonfiles/dockers" #Do not leave a trailing "/"
plex_container_name="plex"
plex_database_directory="$appdata_directory/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases" # <-- I wrote this for the linuxserver.io plex image, it is mapped for it
######################################################################################################################
# YOU'LL LIKELY NEVER NEED TO TOUCH THESE VARIABLES
######################################################################################################################
library_db="com.plexapp.plugins.library.db"
blobs_db="com.plexapp.plugins.library.blobs.db"
cur="$(pwd)"
r='\033[0;31m'
g='\033[0;32m'
b='\033[1;34m'
w='\033[1;37m'
var=''
######################################################################################################################
# DO NOT TOUCH BELOW HERE UNLESS YOU KNOW WHAT YOU'RE DOING
######################################################################################################################

dbCheck(){
    if [ $(find . -type f -iname "$1.test") ]; then
        rm $1.test
    fi
    var=''
    echo -e "${b}Checking ${w}$1's ${b}integrity"
    sqlite3 $1 "DROP index 'index_title_sort_naturalsort'"
    sqlite3 $1 "DELETE from schema_migrations where version='20180501000000'"
    var="$(sqlite3 $1 "PRAGMA integrity_check")"
    return 0
}

createBackup(){
		echo -e "${b}Create backup? ${w}[${g}Yy${w}/${r}Nn${w}]"
        read -n 1 -r -s
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -ne "${b}Creating Backup\r"
            if [ $(find . -type f -iname "$library_db-$(date -I)") ]; then
                echo -e "${w}$library_db-$(date -I) ${b}already exists.${r}\nDo you wish to overwrite this file? ${w}[${g}Yy${w}/${r}Nn${w}]"
                read -n 1 -r -s
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm "$library_db-$(date -I)" &> /dev/null
					rm "$blobs_db-$(date -I)" &> /dev/null
                    cp -n $library_db $library_db-$(date -I)
					cp -n $blobs_db $blobs_db-$(date -I)
                    echo -e "${b}Backups Created (Incase of corruption, restore BOTH):\n${w}($library_db-$(date -I))\n($blobs_db-$(date -I))"
                else
                    echo -e "${b}Backup not created - ${w}Original backup preserved"
                fi #end of backup overwrite check
            else
                cp -n $library_db $library_db-$(date -I)
				cp -n $blobs_db $blobs_db-$(date -I)
                echo -e "${b}Backups Created (Incase of corruption,restore BOTH):\n${w}($library_db-$(date -I))\n($blobs_db-$(date -I))"
            fi #end of backup existence check
			
		fi #end of backup reply check
		return 0
}

echo -e "\nThis script is intended to check and repair your plex media database file if possible\nThis works fine for me, but ${g}I'm not making any guarantees${w}\n${r}I am not responsible for any damages or lost data you incur from using this script${w}\n(especially if you modify it)\n\nDo you wish to continue?[${g}Yy${w}/${r}Nn${w}]"
read -n 1 -r -s
clear
cd "$plex_database_directory" &> /dev/null #goto db location
if [[ ! -f "$library_db" ]]; then
    if [ -f "$appdata_directory/$plex_container_name/Library/Application Support/Plex Media Server/Plug-in Support/Databases/$library_db" ]; then
        plex_database_directory="$appdata_directory/$plex_container_name/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
        cd "$plex_database_directory"
    else
        var="${b}######################################################################\n${r}Error: $library_db not found in expected directory\n${b}######################################################################\n${w}Make sure that the following variable is correctly mapped for you\nIf not, edit this file and change it (it's near the top of the file)\n\n${g}appdata_directory = ${w}$appdata_directory\n${b}######################################################################"
    fi
fi
if [[ ! "$plex_container_name" == $(docker ps -f "name=$plex_container_name" --format "{{.Names}}") ]] ; then
    var="$var\n\n${b}######################################################################\n${r}Error: Docker container $plex_container_name not found\n${b}######################################################################\n${w}Make sure that the following variable is correctly mapped for you\nIf not, edit this file and change it (it's near the top of the file)\n\n${g}plex_container_name = ${w}$plex_container_name\n${b}######################################################################"
fi
if [ ! hash sqlite3 &> /dev/null ]; then
    var="$var\n\n${b}######################################################################\n${r}Error: \"${w}SQLite3${r}\" is not an available command!\n${b}######################################################################\n${w}Try installing the ${g}dev pack${w} from ${b}Community Applications${w}.\nGo to ${g}Settings (Unraid Settings)${w} -> ${g}Dev Pack${w} -> ${g}enable sqlite3${w}\n${b}######################################################################\n"
fi
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    var="${r}Terminating Script"
fi
if [ ! "$var" == "" ]; then
    echo -e "$var"
    exit
else
    clear
    echo -ne "Copying Library Database File...\r"
    cp $library_db $library_db.test && #Make a copy of the current DB File
    echo -e "                                                                                                  \r${b}Databse File${w} ($library_db)${b} copied as ${w}($library_db.test)"
    echo -en "Doing ${b}SQLite3${w} Stuff...\r"
    dbCheck $library_db.test
    rm $library_db.test
    echo -e "Done"
    if [ "ok" == "$var" ]; then
        echo -e "${g}Database file is valid ^__^"
		createBackup    
    else
        echo -e "${r}Database integrity check returned errors!:\n$var\n${b}Attempt repair now? ${w}(This script will terminate Plex and restart it after the script has completed)[${g}Yy${w}/${r}Nn${w}]"
        read -n 1 -r -s
        echo $REPLY
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -ne "${b}Creating copy of corrupted database in case of this scripts fails ${w}($library_db.original)                                                                                                                                                                \r"
            cp $library_db $library_db.original
            echo -en "                                                                                                                                           \r${b}Copy saved as $library_db.original\nKilling PLEX to avoid corruption\r                                                                                                                             \r"
            docker kill $plex_container_name &> /dev/null &&
            echo -en "                                                                                     \r${g}$plex_container_name terminated\nRepairing Database\r${w}"
            cp $library_db $library_db.original
            sqlite3 $library_db "DROP index 'index_title_sort_naturalsort'"
            sqlite3 $library_db "DELETE from schema_migrations where version='20180501000000'"
            sqlite3 $library_db .dump > dump.sql
            rm $library_db
            rm $library_db-shm &> /dev/null
            rm $library_db-wal &> /dev/null
            sqlite3 $library_db < dump.sql

            echo -en "                                                                                                         \r${g}Completed database repair attempt\n${b}Checking repaired database for errors...\r"
            dbCheck $library_db
            if [ "ok" == "$var" ];then
                echo -e "                                                                                                        \r${g}Database file returned no errors!"
				createBackup
            else
                echo -e "                                                                                                         \r${r}Database integrity check returned errors - repair failed!\nPlease restore a backup of your database"
            fi #end of repaired database check
            echo -en "                                                                                 \rRestarting $plex_container_name\r" &&
            docker start $plex_container_name &> /dev/null &&
            echo -e "$plex_container_name restarted succesfully"
        fi #end of Database repair
    fi #end of "OK" check
fi #end of sqlite3 module Check
rm dump.sql &> /dev/null
cd "$cur"
read -n 1 -s -r -p "Press any key to continue"
clear
echo -e "\r                                                                                   \r${g}Goodbye${w} :-)\n"
unset r g b w var cur library_db blobs_db plex_container_name REPLY appdata_directory plex_database_directory
