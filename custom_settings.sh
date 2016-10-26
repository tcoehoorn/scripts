#! /bin/bash

settings_file="./sites/default/settings.php"

vim -c "70,83s/^/\/\/ /" -c "wq" $settings_file
echo "include_once('local.settings.php');" >> $settings_file
git update-index --assume-unchanged $settings_file
