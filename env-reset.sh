#!/bin/sh
git update-index --no-assume-unchanged modstation.int
sed -i '/# <env-setup START>/,/# <env-setup END>/d' .git/config
