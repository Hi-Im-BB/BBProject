#!/bin/bash
OUTPUT="$(cat /usr/lib/zabbix/externalscripts/output.yaml)"
STATUS=$(echo "$OUTPUT" | grep "status:" | cut -d "'" -f2)
if [ $STATUS == "OK" ]
then
        echo "1"
else
        echo "2"
fi