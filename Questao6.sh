#!/bin/bash

INPUT = "Output da outra aplicacao"
STATUS=$(echo "$INPUT" | grep "status:" | cut -d "'" -f2)

if [ $STATUS != "OK" ]
then
    echo "1"
else
    echo "2"