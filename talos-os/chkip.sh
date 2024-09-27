#!/bin/bash
ping -c 1 -W 1 $1 > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "$1 \tup"  || echo -e "$1 \tdown"