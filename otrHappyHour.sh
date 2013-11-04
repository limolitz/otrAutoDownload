#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrHappyHour.sh configFolder"
        exit 1
fi


tmpFile="/tmp/otr_happyHour_new.txt"
lockFile="$1/happyHour.lock"

source $1/otr.conf

touch $lockFile
echo $$ > $lockFile
echo -n "" > $tmpFile

uniq $1/otrHappyHourLinks.txt | while read line; do
   /bin/echo "Downloading $line"
   /usr/bin/aria2c $line -d /media/hdd/aria2 -m 0 --retry-wait=30 --auto-file-renaming=false --on-download-complete= >/dev/null
   download=$?
   retry=false
   case $download in
   	0)
				echo "$line downloaded."
				;;
    13)
				echo "File already exists."
				;;
    18)
     		echo "Error: aria2 could not create directory."
        retry=true
     		;;
    *)
        echo "Error: $line not downloaded. Unhandled status $download"
        retry=true
        ;;
    esac
    # if download file, add link again for next run
    if $retry ; then
      echo "Retrying $line"
      echo $line >> $tmpFile
    fi
done

/bin/rm $1/otrHappyHourLinks.txt
mv $tmpFile $1/otrHappyHourLinks.txt
/bin/rm $lockFile
