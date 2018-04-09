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

startTime=$(($OTRSTARTHAPPYHOURHOUR*60+$OTRSTARTHAPPYHOURMINUTE))
endTime=$(($OTRENDHAPPYHOURHOUR*60+$OTRENDHAPPYHOURMINUTE))

uniq $1/otrHappyHourLinks.txt | while read line; do
  filename=$(basename $line)
  host=$(echo "$line" | awk -F/ '{print $3}')
  # check if this is a direct download from OTR and defer it if we are not in the happy hour
  directDownload=$(echo "$line" | /bin/grep -oP "(81\.95\.11|93\.115\.84|static\.onlinetvrecorder\.com)")
  if test $? -eq 0; then
    echo "This is a direct download."
    # check if we are in happy hour
    currentTime=$(($(env TZ=Europe/Berlin date +%_H)*60+$(env TZ=Europe/Berlin date +%_M)))
    #echo "$startTime vs. $currentTime"
    if (( $currentTime > $startTime && $currentTime < $endTime )); then
      echo "Start Happy Hour Download of $filename."
    else
      echo "Don't start Happy Hour downloads, deferring."
      echo $line >> $tmpFile
      continue
    fi
  else
    echo "Start Mirror Download from $host of $filename."
  fi

  # do the actual download
  /usr/bin/aria2c $line -d $OTRDOWNLOADPATH -m 0 --retry-wait=30 --auto-file-renaming=false --on-download-complete= >/dev/null
  download=$?
  retry=false

  case $download in
    0)
      echo "$filename downloaded."
      # tell transmission to verify this file
      # find out torrent ID
      torrentId=$($1/otrTransmission.sh $1 -v -l | grep "$filename" | awk '{ print $1; }')
      echo "Torrent ID is $torrentId"
      # TODO: check if we got torrent ID
      # TODO: maybe try to add torrent if we didn't get an ID?

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
