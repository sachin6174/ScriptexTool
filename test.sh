#!/bin/bash

# Get all user accounts (excluding system accounts)
users=$(dscl . list /Users | grep -vE '^(daemon|nobody|root|_.*)$')

# Check secure token status for each user
for user in $users; do
    status=$(sysadminctl -secureTokenStatus "$user" 2>&1)
    echo "$status"
done
#
#echo "sachin"
#sleep 1
#echo "sachin"
#sleep 1
#echo "oyioiy"
#false

#!/usr/bin/env bash

# Print your warning to stderr
echo "Warning: required configuration file not found"
#[ -f "/path/to/config.file" ]

