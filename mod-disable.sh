#!/bin/bash

BASEDME="modstation.dme"

if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` [module]"
	exit
fi

#Figure out the #include line...
DMEINCLUDE='#include "modules\\'${1}'\\'${1}'.dme"'

#Make sure the module is enabled.
grep -q "$DMEINCLUDE" $BASEDME
if [ $? -ne 0 ]
then
	echo "Error: Module '${1}' is not enabled."
	exit
fi

#Remove it from the .dme.
sed -i "/${DMEINCLUDE}/d" $BASEDME

#And we're done.
echo "Successfully disabled '${1}'".
exit
