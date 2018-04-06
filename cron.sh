#!/bin/bash

# set to path where scripts are, usually /home/$USER/bin/otrAutoDownload
otrAutoDownloadPath="/home/florin/bin/otrAutoDownload"

source $otrAutoDownloadPath/otr.conf

# grep new links
$otrAutoDownloadPath/otrGrepLinks.sh $otrAutoDownloadPath

if [ -f "$otrAutoDownloadPath/happyHour.lock" ]
then
	echo "Downloads are already running."
else
  $otrAutoDownloadPath/otrHappyHour.sh $otrAutoDownloadPath
fi

# decode new files
$otrAutoDownloadPath/otrDecodeAllFiles.sh $otrAutoDownloadPath
