# Syncthing

Verified: 2026-09-09

## Current deployment

The active Unraid template is `my-syncthing.xml` using
`lscr.io/linuxserver/syncthing`.

| View | Config path |
|---|---|
| Windows | `R:\dockers\appdata\syncthing\config.xml` |
| UNC | `\\TOWER\addonfiles\dockers\appdata\syncthing\config.xml` |
| Unraid | `/mnt/cache_addons/addonfiles/dockers/appdata/syncthing/config.xml` |

The previous configuration is retained at
`R:\dockers\appdata\syncthing_old\config.xml`. The older `binhex-syncthing`
appdata tree is separate and wasn't changed.

The active template maps:

| Container path | Unraid host path | Purpose |
|---|---|---|
| `/config` | `/mnt/cache_addons/addonfiles/dockers/appdata/syncthing` | Configuration and database |
| `/bross` | `/mnt/user/` | General array shares |
| `/backups` | `/mnt/user/Backups/syncthing/` | Syncthing backup tree |
| `/broot` | `/boot` | Flash-drive data |

The Web UI uses host port `8384`. Sync traffic uses TCP and UDP `22000`.
Local discovery uses UDP `21027`.

## Anti-Matter migration

On 2026-09-09, I added the new `Anti-Matter` device to the same 12 folder
definitions as `Anti-Matter-OLD`:

- `3d-models`
- `bross_flash`
- `bross_swag`
- `dad_photos`
- `drone_footage`
- `emu-ps2-cheats`
- `emu-ps2-memcards`
- `emu-ps2-savestates`
- `emu-ps3-savedata`
- `emu-xbox-xemufiles`
- `ha_backups`
- `save-transformers_devestation`

Folder paths, modes, rescan intervals, filesystem watching, permissions, and
versioning were left alone. Both Anti-Matter devices remain attached for now.
Remove the old one only after the new client connects and every folder reports
`Up to Date`.

## Backup and validation

Pre-change backup:

`R:\dockers\appdata\syncthing\config.xml.backup-20260909-105008-before-antimatter-share`

SHA-256:

`40837D3D150450ECA4BFCEE9384602FD5761CB0C9A652CA4C0710DED39F9EA2C`

The updated XML parsed successfully and contained 12 memberships for each
Anti-Matter device. The API at `192.168.1.253:8384` wasn't listening during the
edit, which matched the container being stopped. Runtime validation still
requires the new client to connect, accept its folder paths, and reach
`Up to Date`.

## Rollback

Stop Syncthing. Preserve the current `config.xml` for diagnosis, restore the
dated backup as `config.xml`, then start Syncthing and confirm the old device
and folder map in the Web UI.
