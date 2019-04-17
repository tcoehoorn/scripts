#! /bin/bash

#
# Refresh site - useful when a reset is needed to get rid of strange errors
#

drush updb
drush cc drush
drush rr
