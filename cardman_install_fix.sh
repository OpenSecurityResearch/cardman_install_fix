#!/bin/bash

# quick script to make the omnikey cardman work with bt5/kali
# by brad.antoniewicz@foundstone.com
killall -9 pcscd

localpcsc=`which pcscd`
if [ "${localpcsc}" != "" ]; then
 echo "PCSC-Lite found: ${localpcsc}"
 dropdir=`$localpcsc -v | grep usbdropdir | sed 's/^.*usbdropdir=\(.*\) .*$/\1/' | cut -f1 -d' '`
 echo "Found drop dir: $dropdir"

cd "$dropdir/ifd-ccid.bundle/Contents"
INFO_FILE="Info.plist"
LINE_PRODID=`grep -n "ifdProductID" $INFO_FILE | cut -d: -f 1`
LINE_0x5321=`grep -n 0x5321 $INFO_FILE | cut -d: -f 1`
LINE_VEND=`grep -n "ifdVendorID" $INFO_FILE | cut -d: -f 1`
LINE_FRIEND=`grep -n "ifdFriendlyName" $INFO_FILE | cut -d: -f 1`

if [[ -n $LINE_PRODID && -n $LINE_0x5321 && -n $LINE_VEND && -n $LINE_FRIEND ]]; then
 echo "Backing up $INFO_FILE"
 cp $INFO_FILE $INFO_FILE.backup
 echo -e "Line Numbers:"
 echo -e "\tProductID:  $LINE_PRODID"
 echo -e "\t0x5321: $LINE_0x5321"
 echo -e "\tVendorID: $LINE_VEND"
 echo -e "\tFriendlyName: $LINE_FRIEND"
 echo -e "Offsets:"
 OFFSET=$(($LINE_0x5321 - $LINE_PRODID))
 echo -e "\tGeneral: $OFFSET"
 OFFSET_VEND=$((LINE_VEND + $OFFSET))
 echo -e "\tVendorID: $OFFSET_VEND"
 OFFSET_FRIEND=$((LINE_FRIEND + $OFFSET))
 echo -e "\tFriendlyName: $OFFSET_FRIEND"

 echo "Deleting all the lines!"
 echo -i $LINE_0x5321' d'
 echo -i
sed -i $LINE_0x5321' d;'$OFFSET_VEND' d;'$OFFSET_FRIEND' d;' $INFO_FILE
else
 echo "Could not find a critical line in $INFO_FILE"
fi

else
 echo "PCSC-Lite is not found in current path!"
 echo "Retry with appropriate user or go visit"
 echo "http://alioth.debian.org/projects/pcsclite/"
 echo "and install the latest version of pcsc-lite."
 fi

