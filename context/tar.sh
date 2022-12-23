#!/bin/bash

dir=/backup

cd /

if [ -z "$(ls -A ${dir})" ]; then
   echo "${dir} is empty"
else 
   ls backup/ | while read file;
   do 
      tar cf /tar/DB.$file.tar /backup/$file
      echo "$(date +%Y-%m-%d-%H%M%S) - ${file}" #>> /log/tar.log
   done

   ls tar/ | while read object;
   do
      /usr/local/bin/aws s3 --endpoint-url  https://eu2.contabostorage.com/ mv --quiet /tar/$object s3://backup-docker-mirth
   done
   cd /
   #rm /tar/*
   rm $dir/*
fi
