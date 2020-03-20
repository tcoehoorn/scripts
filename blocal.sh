#! /bin/bash

FILE="./build/behat/behat.yml"
IP_ADDR=$(ipconfig | grep -m 1 "IPv4 Address" | awk '{print $NF}' | tr -d "\n")

sed -i "/wd_host/s/localhost/${IP_ADDR%%[[:space:]]}/" $FILE
sed -i "/javascript_session/s/browser_stack/selenium2/" $FILE
sed -i "/base_url/s/\".*\"/\"https:\/\/iip.trdv.site\"/" $FILE
git update-index --assume-unchanged $FILE
