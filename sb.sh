#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: sb.sh <branch>"
    exit
fi

git co $1
git stash apply
git update-index --assume-unchanged sites/default/settings.php
