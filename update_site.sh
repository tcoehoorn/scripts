#! /bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: update_site.sh <site> <env>"
    exit
fi

today=`date +%Y-%m-%d`

backup_dir=$HOME/tmp/backup
sql_file=$1_$2_$today.sql
sql_zip=$sql_file.gz
sql_path=$backup_dir/$sql_zip
files_zip=$1_$2_$today.tar.gz
files_path=$backup_dir/$files_zip
drupal_dir=/vagrant
schema=iip3

if [ ! -e $sql_path ] || [ ! -e $files_path ]; then
    rm $backup_dir/$1_$2_*

    if [ $2 != "live" ] && [ "$3" != "--use-backup" ]; then
      terminus env:clear-cache "$1.$2"
      terminus backup:create "$1.$2" --element="database"
      terminus backup:create "$1.$2" --element="files"
    fi

    terminus backup:get "$1.$2" --element="database" --to=$sql_path
    terminus backup:get "$1.$2" --element="files" --to=$files_path
fi

sudo rm -rf $drupal_dir/sites/default/files

cd $backup_dir

tar xzvf $files_zip -C $drupal_dir/sites/default/
mv $drupal_dir/sites/default/files_* $drupal_dir/sites/default/files
docker exec docker_portal_1 /bin/chown -R www-data:www-data sites/default/files

gunzip $sql_path
mv $sql_file $schema.sql

sed -e "s/impetusmaster/$schema/g" ~/scripts/update_db.sql > update_db_tmp.sql

mysql -u root -h dbhost -p < update_db_tmp.sql

rm update_db_tmp.sql

mv $schema.sql $sql_file
gzip $sql_file

cd $drupal_dir
drush cc all
drush updb -y
php ./private/scripts/disable_scheduled_emails.php
