#! /bin/bash

FILE="./build/behat/behat.yml"
IP_ADDR=$(ipconfig.exe | grep -m 1 "IPv4 Address" | awk '{print $NF}' | tr -d "\n")

sed -i "/wd_host/s/localhost/${IP_ADDR%%[[:space:]]}/" $FILE
sed -i "/javascript_session/s/browser_stack/selenium2/" $FILE
sed -i "/base_url/s/\".*\"/\"https:\/\/iip.trdv.site\"/" $FILE
sed -i "/files_path/s/'.*'/\'\/var\/www\/html\/build\/behat\/files\'/" $FILE
sed -i "/root/s/'.*'/\'\/var\/www\/html\'/" $FILE
sed -i "/binary/s/'.*'/\'\/var\/www\/html\/build\/behat\/bin\/drush\'/" $FILE
git update-index --assume-unchanged $FILE
