#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: st.sh <branch>"
    exit
fi

git update-index --no-assume-unchanged sites/default/settings.php
git stash
git co $1
