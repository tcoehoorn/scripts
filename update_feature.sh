#! /bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: update_feature.sh <client> <env> <site>"
    exit
fi

today=$(date +%Y-%m-%d)

psite=$1
penv=$2
devdir="iip1"

if [ "$#" -eq 3 ]; then
    devdir=$3
fi

backup_dir=$HOME/tmp/backup
sql_file="$psite"_"$penv"_"$today".sql
sql_zip=$sql_file.gz
sql_path=$backup_dir/$sql_zip
files_zip="$psite"_"$penv"_"$today".tar.gz
files_path=$backup_dir/$files_zip
drupal_dir=$HOME/work/impetus/$devdir
client="$psite.$penv"
container=docker_"$devdir"_1

if [ ! -e "$sql_path" ] || [ ! -e "$files_path" ]; then
    rm "$backup_dir"/"$psite"_"$penv"_*

    # backups are created daily on live sites
    if [ "$penv" != "live" ]; then
      terminus env:clear-cache "$client"
      terminus backup:create "$client" --element="database"
      terminus backup:create "$client" --element="files"
    fi

    terminus backup:get "$client" --element="database" --to="$sql_path"
    terminus backup:get "$client" --element="files" --to="$files_path"
fi

sudo rm -rf "$drupal_dir"/sites/default/files

cd "$backup_dir"

tar xzvf "$files_zip" -C "$drupal_dir"/sites/default/
mv "$drupal_dir"/sites/default/files_"$penv" "$drupal_dir"/sites/default/files
docker exec "$container" /bin/chown -R www-data:www-data sites/default/files

gunzip "$sql_path"
mv "$sql_file" "$devdir".sql

sed -e "s/impetusmaster/$devdir/g" ~/scripts/update_db.sql > update_db_tmp.sql

mysql -u root -p -h dbhost < update_db_tmp.sql

rm update_db_tmp.sql

mv "$devdir".sql "$sql_file"
gzip "$sql_file"

cd ~/work/impetus/"$devdir"

docker exec "$container" drush cc all
docker exec "$container" drush updb -y

php ./private/scripts/disable_scheduled_emails.php
