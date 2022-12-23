#!/bin/bash

date=$(date +%Y%m%d)

echo "$(</run/secrets/mysql-cnf )" | while IFS=, read -r a b c;
do mysqldump --login-path=$a --complete-insert --routines --triggers --single-transaction --quick --all-databases > /backup/$a-$date.dump.sql;
    size=$(du -h /backup/"$a-$date".dump.sql);
    echo "$(date +%Y-%m-%d-%H%M%S) * host: $a, filesize: $size" >> /log/mysqldump.log;
done
/opt/tar.sh

# do mysql --login-path=$a -N -e 'show databases' | while read dbname;
#     do mysqldump --login-path=$a --complete-insert --routines --triggers --single-transaction "$dbname" > /backup/$a."$dbname".$new_fileName;
#         size=$(du -h /backup/"$a.$dbname".$new_fileName);
#         echo "$(date +%Y-%m-%d-%H%M%S) * host: $a, database: $dbname, filesize: $size" >> /log/mysqldump.log;
#     done
# done


