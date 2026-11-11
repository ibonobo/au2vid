#!/data/data/com.termux/files/usr/bin/bash
IMG=~/storage/shared/Pictures/cover.jpg
OUTDIR=~/storage/shared/DCIM/AudioVideos
mkdir -p "$OUTDIR"

in="$1"
base=$(basename "${in%.*}")
out="$OUTDIR/$base.mp4"

if [ -e "$out" ]; then
  msg="Output already exists, not overwriting: $out"
  echo "$msg" >&2
  termux-notification -t "Conversion aborted" -c "$msg"
  exit 1
fi

ffmpeg -n -loop 1 -framerate 2 -i "$IMG" -i "$in" \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
  -r 10 -c:v libx264 -tune stillimage -preset veryfast \
  -c:a aac -b:a 192k -shortest -movflags +faststart "$out" \
&& termux-media-scan "$out" \
&& termux-notification -t "Video ready" -c "$base.mp4" \
|| termux-notification -t "Conversion failed" -c "$base"
