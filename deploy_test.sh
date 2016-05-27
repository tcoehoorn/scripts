#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: deploy_test.sh <deploy-note>"
    exit
fi

sites=( "impetusmaster" "impetusdemo" "novonordisk2" )
client_sites=( "novonordisk2" )

for site in "${sites[@]}"
do
    yes | terminus site upstream-updates apply --updatedb --site="$site" --env="dev"
    terminus drush "cc all" --site="$site" --env="dev"
done

for client in "${client_sites[@]}"
do
    terminus site deploy --sync-content --cc --updatedb --note="$1" --site="$client" --env="test"
    terminus drush "cc all" --site="$client" --env="test"
done
