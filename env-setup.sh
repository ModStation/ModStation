#!/bin/sh
git update-index --assume-unchanged modstation.int
echo '
# <env-setup START>
[merge "merge-dmm"]
	name = mapmerge driver
	driver = ./tools/mapmerge/mapmerge.sh %O %A %B
# <env-setup END>' >> .git/config
