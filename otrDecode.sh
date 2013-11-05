#!/bin/bash
if [[ -z "$1" ]]; then
        echo "Please call with ./otrDecode.sh configFolder fileName"
        exit 1
fi

source $1/otr.conf
echo "Decoding $2 with user $OTREMAIL into $OTROUTPUTPATH"
$OTRQEMUPATH/bin/qemu-x86_64 -L $OTRQEMUPATH $OTRQEMUPATH/bin64/otrdecoder-64 -e $OTREMAIL -p $OTRPASSWORD -i $2 -o $OTROUTPUTPATH
exit $?
