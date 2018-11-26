#!/bin/bash


# multimedia files

ffmpeg -i orig/pexels-video-857601.mkv -i orig/freesound-365215.wav  -ss 0 -t 15.42 -c:v libx264 -profile:v main -vf scale=640:-1 -c:a libfdk_aac  -b:a 256k  h264-aac-2ch.mkv

ffmpeg -i orig/pexels-video-857601.mkv -i orig/freesound-365215.wav  -ss 0 -t 15.42 -c:v libxvid -crf 10 -vf scale=640:-1 -c:a libmp3lame -b:a 256k xvid-mp3-2ch.avi

