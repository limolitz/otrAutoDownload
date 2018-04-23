#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrTransmission.sh configFolder [-v]"
        exit 1
fi

source $1/otr.conf

if [ "$2" = "-v" ]; then
	args=${@:3}
	verbose=0
else
	args=${@:2}
	verbose=1
fi

#echo "Calling transmission-remote localhost --auth $OTRTRANSMISSIONUSER:$OTRTRANSMISSIONPASSWORD \"$args\""

response=$(/usr/bin/transmission-remote localhost --auth $OTRTRANSMISSIONUSER:$OTRTRANSMISSIONPASSWORD $args)

echo "$args: $response" >> otrTransmission.log

# if we got the -a (add) option or -t (specific torrent), check if we had success
if [ "${args:0:2}" == "-a" ] || [ "${args:0:2}" == "-t" ]; then
	success=$(echo "$response" |  grep "success")
	if test $? -eq 0; then
		if test $verbose -eq 0; then
			echo "$response"
		fi
		exit 0
	else
		echo "$response" 1>&2
		exit 1
	fi
elif [ "${args:0:2}" == "-l" ]; then
	# always print for -l (list) option
	echo "$response"
else
	if test $verbose -eq 0; then
		echo "$response"
	fi
fi