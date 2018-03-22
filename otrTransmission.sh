#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrTransmission.sh configFolder"
        exit 1
fi

source $1/otr.conf

response=$(/usr/bin/transmission-remote localhost --auth $OTRTRANSMISSIONUSER:$OTRTRANSMISSIONPASSWORD "${@:2}")
success=$(echo "$response" |  grep "success")
if test $? -eq 0; then
	echo "${@:2}: $response" >> otrTransmission.log
	exit 0
else
	echo "$response" 1>&2
	exit 1
fi