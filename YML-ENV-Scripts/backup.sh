#!/bin/bash

# traverse ~/* directories
# escape trailing slash from dir/
# call tar.sh for each directory

cd /home/docker-user/
ls -d */ | while read dir;
do 
/home/docker-user/backup/YML-ENV-Scripts/tar.sh "$(/home/docker-user/backup/YML-ENV-Scripts/escapeslash.sh "$dir")";
done



