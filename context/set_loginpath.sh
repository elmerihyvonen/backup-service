#!/usr/bin/expect -f

log_user 0

set host [lindex $argv 0];
set user [lindex $argv 1];
set pass [lindex $argv 2];

spawn mysql_config_editor set --login-path=$host --host=$host --user=$user --password
expect "Enter password: "
send "$pass\n"
expect eof
