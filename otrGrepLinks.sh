#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrGrepLinks.sh configFolder"
        exit 1
fi

inFile="/tmp/otr.txt"
outFile="/tmp/otr_grep.txt"

source $1/otr.conf

for inFile in $OTRINCOMINGMAILSPATH/*; do
	if [ -f "$inFile" ]; then
		# grep for torrent link
		#/usr/bin/tr -d '=\n' < $inFile | /bin/grep -oP '"http://.*xbt_torrent_create.php[^"]*[a-z]"' | /bin/grep -oP "3D.*otrkey" | /bin/grep -oP '[^3D].*' >> $outFile

		# grep for direct download link for happy hour download
		directDownload=$(/bin/grep -oP "http://81\.95\.11[^>]*(otrkey|avi|mp4){1}" $inFile)
		if test $? -ne 0; then
			subject=$(cat "$inFile" | grep "Subject: ")
			mailDate=$(cat "$inFile" | grep "Date: ")
			echo "Grep not successful on $subject from $mailDate" 1>&2
		else
			echo "$directDownload" >> $1/otrHappyHourLinks.txt
			json=$(printf '{"topic": "otrAutoDownload","measurements": {"newLinkToFile": "%s"}}' "$directDownload")
      echo "$json" | /home/florin/bin/mqttsend/mqttsend.sh
		fi

		# grep for filename from direct download link for torrent download
		/bin/grep -oP "http://81\.95\.11[^>]*(otrkey){1}" $inFile | grep -oP "[^/]*otrkey" >> $outFile
		cat $outFile | while read line; do
			# grep date from file
			date=$(/bin/echo $line | egrep -o "[0-9]{2}\.[0-9]{2}\.[0-9]{2}")
			#/bin/echo "Adding $line (with date $date) to torrent"
			$1/otrTransmission.sh $1 -a "http://81.95.11.2/torrents/$date/$line.torrent"
			#/usr/bin/transmission-remote localhost -a "http://otr.dwolp.de/torrent_dl.php?datei=$line"
		done
		mv $inFile $OTRINCOMINGMAILSPATH/old
		rm $outFile
	fi
done
