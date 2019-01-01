#!/bin/bash

# Upmix to create the 6-channel content

VINPUT="-i orig/pexels-video-857601.mkv"
AINPUT="-ss 0 -t 15.42 -i orig/freesound-365215.wav"

VSCALE="-vf scale=640:-1"

# Condecs and parameters taken from
# https://trac.ffmpeg.org/wiki/Encode/HighQualityAudoi

declare -A vcodecs
vcodecs["h264"]="-c:v libx264 -profile:v main"
vcodecs["h265"]="-c:v libx265"
vcodecs["xvid"]="-c:v mpeg4 -profile:v 15 -level 5 -qscale:v 11"

declare -A acodecs
acodecs["aacLC"]="-c:a libfdk_aac -b:a 256k"
acodecs["aacHE"]="-c:a libfdk_aac -profile:a aac_he"
acodecs["mp3"]="-c:a libmp3lame -b:a 256k"
acodecs["ac3"]="-c:a ac3        -b:a 256k -ar 48000"
acodecs["mp2"]="-c:a mp2        -b:a 320k"
acodecs["opus"]="-c:a libopus -b:a 128k"
acodecs["vorbis"]="-c:a libvorbis -aq 4"
acodecs["flac"]="-c:a flac"
acodecs["dts"]="-c:a dts -strict -2"

declare -A vcontainers
declare -A acontainers

vcontainers["mkv"]="h264 h265 xvid"
acontainers["mkv"]="aacLC aacHE ac3 opus vorbis flac dts"

vcontainers["avi"]="xvid"
acontainers["avi"]="ac3"

vcontainers["mp4"]="h264 xvid"
acontainers["mp4"]="ac3 aacLC aacHE"

for fmt in ${!vcontainers[@]}; do
    for vcod in ${vcontainers[${fmt}]}; do
	# For some reason, mp4 won't allow the XVID tag in the metadata
	VTAG=""
	if [[ $vcod == xvid ]]; then VTAG="-vtag xvid" ; fi
	if [[ $fmt == mp4 ]]; then VTAG="" ; fi
	for acod in ${acontainers[${fmt}]}; do
	    echo ffmpeg -n $VINPUT $AINPUT -filter_complex "'[1:a]pan=5.1(side)|FL=FL|FR=FR|LFE<FL+FR|SL=FL|SR=FR[a]'" -map 0:v -map -1:a -map "'[a]'" ${vcodecs[${vcod}]} $VSCALE $VTAG ${acodecs[${acod}]} $vcod-$acod-6ch.$fmt
	    ffmpeg -n $VINPUT $AINPUT -filter_complex "[1:a]pan=5.1(side)|FL=FL|FR=FR|LFE<FL+FR|SL=FL|SR=FR[a]" -map 0:v -map -1:a -map "[a]" ${vcodecs[${vcod}]} $VSCALE $VTAG ${acodecs[${acod}]} $vcod-$acod-6ch.$fmt
	done
    done
done

# for opus, 5:1(side) does not work, only this seems to work:

rm -f *opus-6ch*

for vcod in ${vcontainers[mkv]}; do
    # For some reason, mp4 won't allow the XVID tag in the metadata
    VTAG=""
    if [[ $vcod == xvid ]]; then VTAG="-vtag xvid" ; fi
    echo ffmpeg -n $VINPUT $AINPUT  ${vcodecs[${vcod}]} $VSCALE $VTAG ${acodecs[opus]} $vcod-opus-6ch.mkv
    ffmpeg -n $VINPUT $AINPUT -af aformat=channel_layouts="5.1" ${vcodecs[${vcod}]} $VSCALE $VTAG ${acodecs[opus]} $vcod-opus-6ch.mkv
done

exit

ffmpeg -i orig/pexels-video-857601.mkv -ss 0 -t 15.42 -i orig/freesound-365215.wav -af aformat=channel_layouts="5.1(side)" -vf scale=640:-1 -c:v libx265 -c:a libopus -b:a 128k h265-opus-6ch.mkv
