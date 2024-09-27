#!/bin/bash
for ((i=$1; i>0; i--)); do
    echo -ne " Esperar por $i segundos $2\r"
    sleep 1
done