#! /bin/bash

#
# Download xdebug cachegrind files
#

WORK_DIR=/cygdrive/c/Users/tcoeh/work/impetus
CACHEGRIND_DIR=$WORK_DIR/tmp/cachegrind

pushd $WORK_DIR/vagrant

vagrant ssh -c "rm -rf /home/vagrant/tmp/tmp; docker cp docker_portal_1:/tmp /home/vagrant/tmp/"
rm -rf $CACHEGRIND_DIR
vagrant scp default:/home/vagrant/tmp/tmp $(cygpath -d "$WORK_DIR/tmp") 
vagrant ssh -c "rm -rf /home/vagrant/tmp/tmp"
mv $WORK_DIR/tmp/tmp $CACHEGRIND_DIR

popd
