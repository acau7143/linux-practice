#!/bin/bash

ps=`ps --no-header -eo pid`

for p in $ps
do
        if ! [ -e "/proc/$p" ]; then
                continue
        fi

        comm=$(awk '{print $2}' "/proc/$p/stat")
        flag=$(awk '{print $9}' "/proc/$p/stat")

        if (( $flag & 0x00200000 )); then
                echo "$comm is kernel task"
        fi

done

