#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: update_site.sh <site> <env>"
    exit
fi

terminus site clear-cache --site="$1" --env="$2"
terminus site backups create --element="database" --site="$1" --env="$2"
terminus site backups get --element="database" --to=$HOME/tmp --latest --site="$1" --env="$2"
terminus site backups create --element="files" --site="$1" --env="$2"
terminus site backups get --element="files" --to=$HOME/tmp --latest --site="$1" --env="$2"

sudo rm -rf ~/work/impetus/$1/sites/default/files.bak
mv ~/work/impetus/$1/sites/default/files/ ~/work/impetus/$1/sites/default/files.bak

cd ~/tmp

tar xzvf $1_$2*.tar.gz -C ~/work/impetus/$1/sites/default/
mv ~/work/impetus/$1/sites/default/files_* ~/work/impetus/$1/sites/default/files
chmod -R 777 ~/work/impetus/$1/sites/default/files

rm $1_*.tar.gz

gunzip $1_*.sql.gz

mv $1_*.sql $1.sql

sed -e "s/impetusmaster/$1/g" ~/scripts/update_db.sql > update_db_tmp.sql

mysql -u root -p < update_db_tmp.sql

rm update_db_tmp.sql

cd ~/work/impetus/$1

drush en bootstrap_tour -y
drush dis redis -y
drush cc all
