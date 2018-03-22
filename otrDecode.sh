#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrDecode.sh configFolder fileName"
        exit 1
fi

source $1/otr.conf
echo "Decoding $2 with user $OTREMAIL into $OTROUTPUTPATH"
/home/florin/bin/otrpidecoder -d -e $OTREMAIL -p $OTRPASSWORD -D $OTROUTPUTPATH $2 2>&1
exit $?
