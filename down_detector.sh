#!/bin/bash
PAGINA="$(wget -q -O - https://downdetector.com/fora-do-ar/$1/)"
STATUS=$(echo "$PAGINA" | grep "status:" | cut -d "'" -f2)
if [ $STATUS == "success" ]
then
        echo "1"
elif [ $STATUS == "warning" ]
then
        echo "2"
else
        echo "3"
fi