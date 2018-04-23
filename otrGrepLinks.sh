#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrGrepLinks.sh configFolder"
        exit 1
fi

inFile="/tmp/otr.txt"

source $1/otr.conf

for inFile in $OTRINCOMINGMAILSPATH/*; do
	if [ -f "$inFile" ]; then
		# grep for direct download link for happy hour download
		directDownload=$(/bin/grep -oP "http://[81\.95\.11|93\.115\.84][^>]*(otrkey|avi|mp4){1}" $inFile)
		if test $? -ne 0; then
			subject=$(cat "$inFile" | grep "Subject: ")
			mailDate=$(cat "$inFile" | grep "Date: ")
			echo "Grep not successful on $subject from $mailDate" 1>&2
		else
			# check if the file is already present
			filename=$(basename "$directDownload")
			fullPath="$OTRDOWNLOADPATH/$filename"

			if [ -f "$fullPath" ]; then
				echo "File $filename already exists. Don't download again."
			else
				# store in download queue
				echo "$directDownload" >> $1/otrHappyHourLinks.txt
				# tell MQTT about download
				json=$(printf '{"topic": "otrAutoDownload","measurements": {"newLinkToFile": "%s"}}' "$directDownload")
	      echo "$json" | /home/florin/bin/mqttsend/mqttsend.sh

				# grep for filename from direct download link for torrent download

				# grep date from filename
				date=$(/bin/echo $filename | egrep -o "[0-9]{2}\.[0-9]{2}\.[0-9]{2}")
				#/bin/echo "Adding $filename (with date $date) to torrent"
				# Add to transmission
				$1/otrTransmission.sh $1 -a "http://81.95.11.2/torrents/$date/$filename.torrent"
			fi
		fi
		mv $inFile $OTRINCOMINGMAILSPATH/old
	fi
done
