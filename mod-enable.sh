#!/bin/bash

BASEDME="modstation.dme"
if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` [module]"
	exit
fi

# Checks for module files.
if [ ! -d "modules/${1}" ]
then
	echo "Error: Module '$1' doesn't exist."
	exit
fi

if [ ! -f "modules/${1}/${1}.dme" ]
then
	echo "Error: Module '${1}' doesn't have a .dme file."
	exit
fi

if [ ! -f "modules/${1}/${1}.int" ]
then
	echo "Warning: Module '${1}' doesn't have a .int file."
fi

# Module is (mostly) valid, we can continue.

#Generate the #include line...
DMEINCLUDE='#include "modules\\'${1}'\\'${1}'.dme"'

#Make sure the module isn't already enabled.
grep -q "$DMEINCLUDE" $BASEDME
if [ $? -eq 0 ]
then
	echo "Error: Module '${1}' is already enabled."
	exit
fi

#Apply the #include line to the base .dme.
sed -i "/\/\/ BEGIN_INCLUDE/ { N; s/\/\/ BEGIN_INCLUDE\n/${DMEINCLUDE}\n&/ }" \
	$BASEDME

#And we're done.
echo "Successfully enabled '${1}'".
exit
