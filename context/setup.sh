#!/bin/bash

# Setup aws-cli on boot
source /run/secrets/aws-cnf
./opt/aws_setup.sh $access_key $secret

aws --endpoint-url https://eu2.contabostorage.com s3api put-bucket-lifecycle-configuration --bucket backup-docker-mirth --lifecycle-configuration file://lifecycle-policy.json

./opt/mysql_config_editor.sh 

touch /var/log/cron.log
cron && tail -f /var/log/cron.log
