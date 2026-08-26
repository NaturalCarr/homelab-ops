#!/usr/bin/env python3
"""
transcode.py - HDR-aware x265 transcode pipeline.

Re-encodes video to HEVC while preserving (or converting) the source's dynamic
range. The interesting part is the tone-mapping: libplacebo runs on the Vulkan
device, so the colour conversion happens on the GPU rather than pegging the CPU
for the length of a feature film.

Three modes:

  hdr10  Preserve HDR10. Carries the BT.2020 primaries, PQ transfer function,
         and mastering-display metadata through to the output, so the result
         still triggers HDR on a capable display.

  hlg    Preserve Hybrid Log-Gamma (broadcast HDR).

  sdr    Tone-map HDR down to BT.709 for displays that can't do HDR. Without
         this, HDR content on an SDR display looks washed out and grey.

The x265 parameters are per-mode rather than shared: HDR needs the metadata
signalling flags (repeat-headers, hdr10, master-display) that are meaningless
in SDR, and SDR benefits from psychovisual tuning that HDR grading conflicts
with.

Usage:
    ./transcode.py -i input.mkv -o output --bitrate 15000 --type hdr10
    ./transcode.py -i input.mkv -o output --bitrate 8000 --type sdr --preset medium

Requires ffmpeg built with libplacebo, Vulkan, and libx265.
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

# Colour-management filter chains. Each uploads to the Vulkan device, converts,
# then downloads — the GPU round trip is what keeps this off the CPU.
VIDEO_FILTERS = {
    "hdr10": (
        "hwupload,"
        "libplacebo=peak_detect=false:colorspace=9:color_primaries=9:"
        "color_trc=16:range=tv:format=yuv420p10le,"
        "hwdownload,format=yuv420p10le"
    ),
    "sdr": (
        "hwupload,"
        "libplacebo=peak_detect=false:colorspace=bt709:color_primaries=bt709:"
        "color_trc=bt709:range=tv:format=yuv420p10le,"
        "hwdownload,format=yuv420p10le"
    ),
    "hlg": (
        "hwupload,"
        "libplacebo=iw:ih:format=yuv420p10le:format=rgb48le"
    ),
}

# Encoder parameters per mode. vbv-maxrate/bufsize cap the instantaneous rate
# so the result stays within hardware decoder limits on set-top players.
X265_PARAMS = {
    "hdr10": (
        "repeat-headers=1:sar=1:hrd=1:aud=1:open-gop=0:hdr10=1:sao=0:rect=0:"
        "cutree=0:deblock=-3-3:strong-intra-smoothing=0:chromaloc=2:aq-mode=1:"
        "vbv-maxrate=160000:vbv-bufsize=160000:max-luma=1023:max-cll=0,0:"
        "master-display=G(8500,39850)B(6550,23000)R(35400,15650)"
        "WP(15635,16450)L(10000000,1)"
    ),
    "sdr": (
        "deblock=-3-3:vbv-bufsize=62500:vbv-maxrate=50000:fast-pskip=0:"
        "dct-decimate=0:level=5.1:ref=5:psy-rd=1.05,0.15:subme=11:me=umh:"
        "me_range=48"
    ),
    "hlg": "open-gop=0:atc-sei=18:pic_struct=0",
}


def build_command(input_file, output_file, bitrate, mode, preset, ffmpeg):
    """Assemble the ffmpeg argument list for one encode."""
    return [
        ffmpeg,
        "-nostdin",
        "-loglevel", "error",
        "-stats",
        "-y",
        "-init_hw_device", "vulkan=vulkan",
        "-filter_hw_device", "vulkan",
        "-i", str(input_file),
        "-vf", VIDEO_FILTERS[mode],
        "-c:v", "libx265",
        "-preset", preset,
        "-map_chapters", "-1",
        "-an", "-sn",                     # video only; mux audio separately
        "-b:v", f"{bitrate}k",
        "-x265-params", f"{X265_PARAMS[mode]}:preset={preset}",
        str(output_file),
    ]


def encode(input_file, output_file, bitrate, mode, preset, ffmpeg, dry_run=False):
    """Run one encode. Returns ffmpeg's exit code."""
    cmd = build_command(input_file, output_file, bitrate, mode, preset, ffmpeg)

    if dry_run:
        print(" ".join(repr(c) if " " in c else c for c in cmd))
        return 0

    print(f"encoding {input_file.name} -> {output_file.name} [{mode}, {bitrate}k, {preset}]")
    return subprocess.run(cmd).returncode


def main():
    parser = argparse.ArgumentParser(
        description="HDR-aware x265 transcode with GPU tone mapping",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("-i", "--input", required=True, type=Path, help="Input file")
    parser.add_argument("-o", "--output", required=True, type=Path,
                        help="Output path; mode/preset and .mp4 are appended")
    parser.add_argument("--bitrate", required=True, type=int, help="Target video bitrate (kbps)")
    parser.add_argument("--type", required=True, choices=sorted(VIDEO_FILTERS),
                        dest="mode", help="Dynamic-range handling")
    parser.add_argument("--preset", default="slow",
                        choices=["ultrafast", "superfast", "veryfast", "faster",
                                 "fast", "medium", "slow", "slower", "veryslow"],
                        help="x265 preset (default: slow)")
    parser.add_argument("--ffmpeg", default="ffmpeg", help="ffmpeg binary (default: ffmpeg)")
    parser.add_argument("--dry-run", action="store_true", help="Print the command, don't run it")

    args = parser.parse_args()

    # Fail before spending an hour discovering the input was a typo.
    if not args.input.is_file():
        sys.exit(f"error: input not found: {args.input}")

    if args.bitrate <= 0:
        sys.exit(f"error: bitrate must be positive, got {args.bitrate}")

    if not args.dry_run and shutil.which(args.ffmpeg) is None:
        sys.exit(f"error: {args.ffmpeg} not found on PATH")

    output = args.output.with_name(f"{args.output.name}_{args.mode}_{args.preset}.mp4")
    output.parent.mkdir(parents=True, exist_ok=True)

    rc = encode(args.input, output, args.bitrate, args.mode, args.preset,
                args.ffmpeg, args.dry_run)

    if rc != 0:
        sys.exit(f"error: ffmpeg exited {rc}")

    if not args.dry_run:
        print(f"done: {output}")


if __name__ == "__main__":
    main()
