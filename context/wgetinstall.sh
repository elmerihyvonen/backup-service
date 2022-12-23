#!/usr/bin/expect -f

spawn apt-get install wget
expect {Do you want to continue? [Y/n]}
send "y\r"
expect eof