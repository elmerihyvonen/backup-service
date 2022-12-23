#!/bin/bash

# Call this as:
#   ./escapeslash.sh one/ two/ three/ 
#
# Output:
#  one two three

echo ${@%/}