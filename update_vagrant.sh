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
drupal_dir=/cygdrive/c/work/impetus/$devdir
vagrant_dir=/cygdrive/c/work/impetus/vagrant
client="$psite.$penv"
db_container=docker_dbhost_1
db_pwd=
portal_container=docker_portal_1

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

cd "$vagrant_dir"

vagrant upload "$(cygpath -w "$backup_dir/$files_zip")" /vagrant/sites/default/
vagrant ssh -c "sudo rm -rf /vagrant/sites/default/files"
vagrant ssh -c "tar xzvf /vagrant/sites/default/$files_zip -C /vagrant/sites/default/"

vagrant ssh -c "mv /vagrant/sites/default/files_$penv /vagrant/sites/default/files"
vagrant ssh -c "rm /vagrant/sites/default/$files_zip"
vagrant ssh -c "docker exec $portal_container /bin/chown -R www-data:www-data sites/default/files"

cd "$backup_dir"
gunzip "$sql_path"
mv "$sql_file" "$devdir".sql

sed -e "s/impetusmaster/$devdir/g" ~/scripts/update_db_vagrant.sql > update_db_tmp.sql

cd "$vagrant_dir"
vagrant upload "$(cygpath -w "$backup_dir/update_db_tmp.sql")" /tmp/
vagrant upload "$(cygpath -w "$backup_dir/$devdir.sql")" /tmp/
vagrant ssh -c "docker cp /tmp/update_db_tmp.sql $db_container:/tmp/"
vagrant ssh -c "docker cp /tmp/$devdir.sql $db_container:/tmp/"
vagrant ssh -c "docker exec -i $db_container mysql -u root -p$db_pwd < /tmp/update_db_tmp.sql"
vagrant ssh -c "rm /tmp/update_db_tmp.sql"
vagrant ssh -c "rm /tmp/$devdir.sql"
vagrant ssh -c "docker exec $db_container rm /tmp/update_db_tmp.sql"
vagrant ssh -c "docker exec $db_container rm /tmp/$devdir.sql"

cd "$backup_dir"
rm update_db_tmp.sql

mv "$devdir".sql "$sql_file"
gzip "$sql_file"

cd "$vagrant_dir"

vagrant ssh -c "docker exec $portal_container drush cc all"
vagrant ssh -c "docker exec $portal_container drush updb -y"
vagrant ssh -c "docker exec $portal_container php ./private/scripts/disable_scheduled_emails.php"
