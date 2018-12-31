#!/bin/bash

VINPUT="-i orig/pexels-video-857601.mkv"
AINPUT="-ss 0 -t 15.42 -i orig/freesound-365215.wav"

VSCALE="-vf scale=640:-1"

# Condecs and parameters taken from
# https://trac.ffmpeg.org/wiki/Encode/HighQualityAudoi

declare -A vcodecs
vcodecs["h264"]="-c:v libx264 -profile:v main"
vcodecs["h265"]="-c:v libx265"
vcodecs["hvid"]="-c:v libxvid"

declare -A acodecs
acodecs["aacLC"]="-c:a libfdk_aac -b:a 256k"
acodecs["aacHE"]="-c:a libfdk_aac -profile:a aac_he"
acodecs["mp3"]="-c:a libmp3lame -b:a 256k"
acodecs["ac3"]="-c:a ac3        -b:a 256k -ar 48000"
acodecs["mp2"]="-c:a mp2        -b:a 320k"
acodecs["opus"]="-c:a libopus -b:a 128k"
acodecs["vorbis"]="-c:a libvorbis -aq 4"
acodecs["flac"]="-c:a flac"

declare -A vcontainers
declare -A acontainers

vcontainers["mkv"]="h264 h265 xvid"
acontainers["mkv"]="aacLC aacHE ac3 mp3 mp2 opus vorbis flac"

vcontainers["avi"]="xvid"
acontainers["avi"]="mp3 ac3 mp2"

vcontainers["mp4"]="h264 xvid"
acontainers["mp4"]="ac3 mp3 aacLC aacHE mp2"

#TODO:
#MP4-{H264,XviD}-{AC3,AACHE,AACLC}-6ch.mp4
#MKV-{H264,H265,XviD}-{AACHE,AACLC,AC3,DTS,FLAC,Opus,Vorbis}-6ch.mkv
#AVI-XviD-AC3-6ch.avi


for fmt in ${!vcontainers[@]}; do
    for vcod in ${vcontainers[${fmt}]}; do
	for acod in ${acontainers[${fmt}]}; do
	    ffmpeg -n $VINPUT $AINPUT ${vcodecs[${vcod}]} $VSCALE ${acodecs[${acod}]} $vcod-$acod-2ch.$fmt
	done
    done
done

exit
    
ffmpeg -i orig/pexels-video-857601.mkv -i orig/freesound-365215.wav  -ss 0 -t 15.42 -c:v libx264 -profile:v main -vf scale=640:-1 -c:a libfdk_aac  -b:a 256k  h264-aac-2ch.mkv

ffmpeg -i orig/pexels-video-857601.mkv -i orig/freesound-365215.wav  -ss 0 -t 15.42 -c:v libxvid -vf scale=640:-1 -c:a libmp3lame -b:a 256k xvid-mp3-2ch.avi

ffmpeg -i orig/pexels-video-857601.mkv  -ss 0 -t 15.42 -i orig/freesound-365215.wav -c:v libxvid -vf scale=640:-1 -c:a ac3 -b:a 256k -ar 48000 xvid-ac3-2ch.avi


