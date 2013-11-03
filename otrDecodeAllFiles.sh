#!/bin/bash
if [[ -z "$1" ]]; then
	echo "Please call with ./otrDecodeAllFiles.sh configFolder"
	exit 1
fi

source $1/otr.conf

find $OTRDOWNLOADPATH/*.otrkey | while read file; do
    #get media file name, that is, remove the trailing .otrkey
    mediafile=$(echo $(basename $file) | grep -oP ".*[^\.otrkey]")
    # check if resulting file is already in the folder
    if [ -f "$mediafile" ]
    then
        echo "$mediafile existing, therefore already decoded."
        # check if filename was correctly recorded in save file
        grep "$mediafile" $1/otrDecoded.txt >/dev/null
        RETVAL=$?
        [ $RETVAL -eq 1 ] && echo $mediafile >> $1/otrDecoded.txt
    else
        grep "$mediafile" $1/otrDecoded.txt >/dev/null
        RETVAL=$?
        if [ $RETVAL -eq 1 ]
        then
            echo "$mediafile not decoded. Will do."
            $1/otrDecode.sh $1 $file
	    echo $mediafile >> $1/otrDecoded.txt
        else
            echo "$mediafile already decoded once."
        fi
    fi
done
