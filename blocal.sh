#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: blocal.sh <url>"
    exit
fi

FILE="./build/behat/behat.yml"

sed -i "/wd_host/s/localhost/ambrose/" $FILE
sed -i "/javascript_session/s/browser_stack/selenium2/" $FILE
sed -i "/base_url/s/\".*\"/\"http:\/\/www.$1\"/" $FILE
git update-index --assume-unchanged $FILE
