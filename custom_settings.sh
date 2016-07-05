#! /bin/bash

# cat $HOME/scripts/data/settings.php >> $HOME/work/impetus/impetusmaster/sites/default/settings.php
echo "include_once('local.settings.php');" >> ./sites/default/settings.php
