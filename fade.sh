# This script is to apply fade in/out to WAV audio files placed in `raw/` 
# and output the faded audio files (converted to .mp3) to `faded/`.
#
# [Refs]
# https://video.stackexchange.com/a/28280 (add fade in/out with ffmpeg)
# https://stackoverflow.com/a/12952172 (set output audio parameters in ffmpeg)
# https://stackoverflow.com/a/22243834 (ffprobe to get duration of a file)
# https://stackoverflow.com/a/12723330 (floating point arithmetic in Bash)
# https://stackoverflow.com/a/2664746 (remove parents and extension from file paths)

if [[ "$OSTYPE" == "msys" ]]; then
    cwd=`pwd`
    source ~/.bash_profile
    cd $cwd
fi
[[ -d faded ]] || mkdir faded

FADE_OUT_DUR=3.5
FADE_IN_DUR=4
for fp in raw/*wav; do
    dur=`ffprobe -i $fp -show_entries format=duration -v quiet -of csv="p=0"`
    foS=$(bc -l <<< "$dur-$FADE_OUT_DUR")
    outfp=${fp##*/}
    outfp=faded/${outfp%.*}".mp3"

    ffmpeg -i $fp -vn -ar 44100 -b:a 320k -vf fade=in:0:d=$FADE_IN_DUR,fade=out:st=$foS:d=$FADE_OUT_DUR -af afade=in:0:d=$FADE_IN_DUR,afade=out:st=$foS:d=$FADE_OUT_DUR $outfp
done
