#! /bin/bash

settings_file="./sites/default/settings.php"

echo "include_once('local.settings.php');" >> $settings_file
git update-index --assume-unchanged $settings_file
