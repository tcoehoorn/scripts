#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: update_site.sh <site> <env>"
    exit
fi

terminus env:clear-cache "$1.$2"
terminus backup:create "$1.$2" --element="database"
terminus backup:get "$1.$2" --element="database" --to=$HOME/tmp/$1.sql.gz
terminus backup:create "$1.$2" --element="files"
terminus backup:get "$1.$2" --element="files" --to=$HOME/tmp/$1_$2.tar.gz

sudo rm -rf ~/work/impetus/$1/sites/default/files.bak
mv ~/work/impetus/$1/sites/default/files/ ~/work/impetus/$1/sites/default/files.bak

cd ~/tmp

tar xzvf $1_$2.tar.gz -C ~/work/impetus/$1/sites/default/
mv ~/work/impetus/$1/sites/default/files_* ~/work/impetus/$1/sites/default/files
chmod -R 777 ~/work/impetus/$1/sites/default/files

rm $1_$2.tar.gz

gunzip $1.sql.gz

sed -e "s/impetusmaster/$1/g" ~/scripts/update_db.sql > update_db_tmp.sql

mysql -u root -p < update_db_tmp.sql

rm update_db_tmp.sql
rm $1.sql

cd ~/work/impetus/$1

drush cron-disable 'scheduled_pet_cron'
drush cron-disable 'comment_notifications_cron'

drush en bootstrap_tour -y
drush dis redis -y
drush updb
drush cc drush
drush rr
drush cc all

# php ./private/scripts/disable_scheduled_emails.php
