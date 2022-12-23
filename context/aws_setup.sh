#!/usr/bin/expect -f

log_user 0

set access_key [lindex $argv 0];
set secret [lindex $argv 1];

spawn aws configure
expect {AWS Access Key ID [None]:}
send "$access_key\r"
expect {AWS Secret Access Key [None]:}
send "$secret\r"
expect {Default region name [None]:}
send "\r"
expect {Default output format [None]:}
send "\r"
expect eof



