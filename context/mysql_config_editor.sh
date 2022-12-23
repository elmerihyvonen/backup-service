#!/bin/bash

# Setup mysql_config_editor
echo "$(</run/secrets/mysql-cnf )" | while IFS=, read -r a b c;
do
    echo "$(date +%Y-%m-%d-%H%M%S) - Setting MySQL login-path for host: $a" > /log/startup.log
    ./opt/set_loginpath.sh $a $b $c
done






