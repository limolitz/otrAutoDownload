#!/bin/bash

# set to path where scripts are, usually /home/$USER/bin/otrAutoDownload
otrAutoDownloadPath="/home/florin/bin/otrAutoDownload"

source $otrAutoDownloadPath/otr.conf

# grep new links
$otrAutoDownloadPath/otrGrepLinks.sh $otrAutoDownloadPath

# check if happy hour downloads are running
endTime=$(($OTRENDHAPPYHOURHOUR*60+$OTRENDHAPPYHOURMINUTE))

if [ -f "$otrAutoDownloadPath/happyHour.lock" ]
then
	# end downloads if shortly before end of happy hour
	echo -n "It is $(env TZ=Europe/Berlin date +%H:%M), end script by $OTRENDHAPPYHOURHOUR:$OTRENDHAPPYHOURMINUTE: "
	currentTime=$(($(env TZ=Europe/Berlin date +%_H)*60+$(env TZ=Europe/Berlin date +%_M)))
	if (( $currentTime > $endTime ))
  then
    echo "End script."
    pid=$(cat $otrAutoDownloadPath/happyHour.lock)
    $otrAutoDownloadPath/killTree.sh $pid
    rm $otrAutoDownloadPath/happyHour.lock
  else
    echo "Script can run on."
  fi
else
  # start downloads if in happy hour
  #echo -n "It is $(env TZ=Europe/Berlin date +%H:%M)h, start script between $OTRSTARTHAPPYHOURHOUR:$OTRSTARTHAPPYHOURMINUTE h and $OTRENDHAPPYHOURHOUR:$OTRENDHAPPYHOURMINUTE h: "
  startTime=$(($OTRSTARTHAPPYHOURHOUR*60+$OTRSTARTHAPPYHOURMINUTE))
  currentTime=$(($(env TZ=Europe/Berlin date +%_H)*60+$(env TZ=Europe/Berlin date +%_M)))
  #echo "$startTime vs. $currentTime"
  if (( $currentTime > $startTime && $currentTime < $endTime ))
  then
    echo "Start Happy Hour Downloads."
    $otrAutoDownloadPath/otrHappyHour.sh $otrAutoDownloadPath &
  else
    #echo "Don't start Happy Hour Script."
    true
  fi
fi

# decode new files
$otrAutoDownloadPath/otrDecodeAllFiles.sh $otrAutoDownloadPath &
