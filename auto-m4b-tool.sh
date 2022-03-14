#!/bin/bash
# set n to 1
n=1
# variable defenition
inputfolder="/temp/mp3merge/"
outputfolder="/temp/untagged/"
binfolder="/temp/delete/"
m4bend=".m4b"
logend=".log"

#change to the merge folder, keeps this clear and the script could be kept inside the container
cd "$inputfolder"

# continue until $n  5
while [ $n -ge 0 ]; do

	# clear the folders
	rm -r "$binfolder"* 2>/dev/null

	if ls -d */ 2>/dev/null; then
		echo Folder Detected
		for book in *; do
			if [ -d "$book" ]; then
				mpthree=$(find . -maxdepth 2 -type f -name "*.mp3" | head -n 1)
				m4bfile=$outputfolder$book$m4bend
				logfile=$outputfolder$book$logend
				echo Sampling $mpthree
				bit=$(ffprobe -hide_banner -loglevel 0 -of flat -i "$mpthree" -select_streams a -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1)
				echo Bitrate = $bit
				echo The folder "$book" will be merged to "$m4bfile"
				echo Starting Conversion
				m4b-tool merge "$book" -n -q --audio-bitrate="$bit" --skip-cover --use-filenames-as-chapters --audio-codec=libfdk_aac --jobs=4 --output-file="$m4bfile" --logfile="$logfile"
				mv "$inputfolder""$book" "$binfolder"
				mv "$outputfolder""$book".chapters.txt "$outputfolder"chapters
				echo Finished Converting
				echo Deleting duplicate mp3 audiobook folder
			fi
		done
	else
		echo No folders detected, next run 5min...
		sleep 5m
	fi
done
