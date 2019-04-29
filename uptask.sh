#! /bin/bash


if [ "$#" -ne 1 ]; then
    echo "Usage: uptask.sh <num>"
    exit
fi

TASK_FILE=$HOME/scripts/data/current_bug

echo "$1" > $TASK_FILE
