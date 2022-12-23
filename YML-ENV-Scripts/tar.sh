#!/bin/bash

date=$(date +%Y%m%d)

if ! test -e "$1"/*.yml; 
then 
    : # no-op command
elif ! test -e "$1"/.env;
then 
    : # no-op command
else
    echo "Backing up $1 to tar/ volume"
    cp $1/*.yml $1/.env /home/docker-user/backup/FS/$1/
    tar cf /home/docker-user/backup/tar/$1.$date.tar /home/docker-user/backup/FS/$1/
    # tar cf /home/docker-user/backup/tar/$1.$date.tar $1/*.yml $1/.env
    rm /home/docker-user/backup/FS/$1/*.yml
    rm /home/docker-user/backup/FS/$1/.env
    echo "Backup finished"
fi


