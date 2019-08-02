#! /bin/bash

FILE="./build/behat/behat.yml"

sed -i "/wd_host/s/localhost/10.0.0.185/" $FILE
sed -i "/javascript_session/s/browser_stack/selenium2/" $FILE
sed -i "/base_url/s/\".*\"/\"https:\/\/iip.trdv.site\"/" $FILE
git update-index --assume-unchanged $FILE
