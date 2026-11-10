# au2vid
script to make a simple video out of a pic and an audio file

## Goal
I want to slap a landscape pic on an audio recording on my Pixel 4a or Pixel 3 Android and make it a video that can be backed up by Google Photos. The script or app should be called from the Share file menu.

## Termux script
The most flexible way is Termux with ffmpeg and a share hook. Termux appears in the Share menu and runs a script on whatever file you share. I haven't tested this on a Pixel 4a or 3, so try it with a short clip first.

**Setup (once)**

1. Install Termux and Termux:API from F-Droid. The Play Store Termux is outdated.
2. In Termux:
   ```
   pkg install ffmpeg termux-api
   termux-setup-storage
   mkdir -p ~/bin
   ```
3. Put your landscape picture somewhere fixed, e.g. `Pictures/cover.jpg`.

**The hook script**: `~/bin/termux-file-editor` (Termux runs this name when you share a file to it, passing the file path as `$1`):

```bash
#!/data/data/com.termux/files/usr/bin/bash
IMG=~/storage/shared/Pictures/cover.jpg
OUTDIR=~/storage/shared/DCIM/AudioVideos
mkdir -p "$OUTDIR"

in="$1"
base=$(basename "${in%.*}")
out="$OUTDIR/$base.mp4"

ffmpeg -y -loop 1 -framerate 2 -i "$IMG" -i "$in" \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
  -r 10 -c:v libx264 -tune stillimage -preset veryfast \
  -c:a aac -b:a 192k -shortest -movflags +faststart "$out" \
&& termux-media-scan "$out" \
&& termux-notification -t "Video ready" -c "$base.mp4" \
|| termux-notification -t "Conversion failed" -c "$base"
```

Then run `chmod +x ~/bin/termux-file-editor`.

**Use**

Share the audio file, pick **Termux**, and a notification appears when the MP4 is done. The video is a still image at low cost, so it encodes much faster than real time.

**Google Photos backup**

Google Photos backs up `DCIM/Camera` automatically. For the `DCIM/AudioVideos` folder, go to Photos → Settings → Backup → Backup device folders and turn it on. Or change `OUTDIR` to `.../DCIM/Camera` to skip that step. The `termux-media-scan` call is what makes Photos notice the new file.

**Caveats**

- Some apps (certain voice recorders) share a `content://` URI instead of a file. Termux normally copies these into `~/downloads` first, but if your recorder fails, test with the file manager's Share and tell me the error.
- Keep the 16:9 padding if your picture isn't exactly that ratio; otherwise ffmpeg may fail on odd dimensions.

If you'd rather avoid scripting, some "audio to video" apps accept shared audio, but they usually re-encode with watermarks or ads and offer no fixed image/output folder, which is why I'd go with Termux.
