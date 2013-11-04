#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrGrepLinks.sh configFolder"
        exit 1
fi

inFile="/tmp/otr.txt"
outFile="/tmp/otr_grep.txt"

source $1/otr.conf

$1/dropboxUploader/dropbox_uploader.sh download $OTRDROPBOXPATH $inFile
# Grep for torrent file as attachment
/bin/grep -oP "filename=.*otrkey" $inFile | /bin/grep -oP "=.*" | /bin/grep -oP "[^=]*.otrkey$" >> $outFile
# grep for torrent link
/usr/bin/tr -d '=\n' < $inFile | /bin/grep -oP '"http://81.95.11.2.*xbt_torrent_create.php[^"]*[a-z]"' | /bin/grep -oP "3D.*otrkey" | /bin/grep -oP '[^3D].*' >> $outFile
# grep for direct download link for happy hour download
/bin/grep -oP "http://81.95.11.22.*.otrkey" $inFile >> $1/otrHappyHourLinks.txt
# grep for filename from direct download link for torrent download
/bin/grep -oP "http://81.95.11.22.*.otrkey" $inFile | grep -oP "[^/]*otrkey" >> $outFile
cat $outFile | while read line; do
   # grep date from file
   date=$(/bin/echo $line | egrep -o "[0-9]{2}\.[0-9]{2}\.[0-9]{2}")
   /bin/echo "Adding $line (with date $date) to torrent"
   /usr/bin/transmission-remote localhost -a "http://81.95.11.2/torrents/$date/$line.torrent"
   #/usr/bin/transmission-remote localhost -a "http://otr.dwolp.de/torrent_dl.php?datei=$line"
done
/bin/echo "" > $inFile
$1/dropboxUploader/dropbox_uploader.sh upload $inFile $OTRDROPBOXPATH
/bin/rm $outFile
/bin/rm $inFile



