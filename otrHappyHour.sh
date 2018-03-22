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
  filename=$(basename $line)
  /bin/echo "Downloading $filename"
  /usr/bin/aria2c $line -d $OTRDOWNLOADPATH -m 0 --retry-wait=30 --auto-file-renaming=false --on-download-complete= >/dev/null
  download=$?
  retry=false
  case $download in
    0)
      echo "$filename downloaded."
      # tell transmission to verify this file
      # find out torrent ID
      torrentId=$($1/otrTransmission.sh $1 -l | grep "$filename" | awk '{ print $1; }')
      echo "Torrent ID is $torrentId"
      # tell transmission to verify
      $1/otrTransmission.sh $1 -t $torrentId -v
      # tell MQTT
      json=$(printf '{"topic":"otrAutoDownload","measurements":{"downloadedFile": "%s"}}' "$filename")
      echo "$json" | /home/florin/bin/mqttsend/mqttsend.sh
      ;;
    13)
      echo "File $(basename $line) already exists."
      ;;
    18)
      echo "Error: aria2 could not create directory."
      retry=true
      ;;
    *)
      echo "Error: $(basename $line) not downloaded. Unhandled status $download"
      retry=true
      ;;
    esac
    # if download file, add link again for next run
    if $retry ; then
      echo "Retrying $(basename $line)"
      echo $line >> $tmpFile
    fi
done

/bin/rm $1/otrHappyHourLinks.txt
mv $tmpFile $1/otrHappyHourLinks.txt
/bin/rm $lockFile
