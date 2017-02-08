#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: update_site.sh <site> <env>"
    exit
fi

today=`date +%Y-%m-%d`

sql_file=$1_$2_$today.sql
sql_zip=$sql_file.gz
sql_path=$HOME/tmp/$sql_zip
files_zip=$1_$2_$today.tar.gz
files_path=$HOME/tmp/$files_zip

if [ ! -e $sql_path ] || [ ! -e $files_path ]; then
    rm $HOME/tmp/$1_$2_*

    terminus env:clear-cache "$1.$2"
    terminus backup:create "$1.$2" --element="database"
    terminus backup:get "$1.$2" --element="database" --to=$sql_path
    terminus backup:create "$1.$2" --element="files"
    terminus backup:get "$1.$2" --element="files" --to=$files_path
fi

sudo rm -rf ~/work/impetus/$1/sites/default/files.bak
mv ~/work/impetus/$1/sites/default/files/ ~/work/impetus/$1/sites/default/files.bak

cd ~/tmp

tar xzvf $files_zip -C ~/work/impetus/$1/sites/default/
mv ~/work/impetus/$1/sites/default/files_* ~/work/impetus/$1/sites/default/files
chmod -R 777 ~/work/impetus/$1/sites/default/files

gunzip $sql_path
mv $sql_file $1.sql

sed -e "s/impetusmaster/$1/g" ~/scripts/update_db.sql > update_db_tmp.sql

mysql -u root -p < update_db_tmp.sql

rm update_db_tmp.sql

mv $1.sql $sql_file
gzip $sql_file

cd ~/work/impetus/$1

drush en bootstrap_tour -y
drush dis redis -y
drush updb -y
drush cc drush
drush rr
drush cc all

php ./private/scripts/disable_scheduled_emails.php
