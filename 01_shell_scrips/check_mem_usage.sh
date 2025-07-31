#!/bin/bash

if [ "$1" == "" ];then
        mem_usage=`ps --no-header -eo pmem,comm | awk -F " " '{print $1}' | paste -sd+ | bc `
        echo "Entire memory usage : $mem_usage %"

        echo "if particular process, please enter proccess name"
        exit 0
fi

p_count=`ps -eo comm | grep -wc $1`

if [ "$p_count" == "0" ]; then
        echo "Error: '$1' process don't exist"
        exit 0
fi

mem_usage=`ps -eo pmem,comm | grep -we "$1" | awk -F " " '{print $1}' | paste -sd+ | bc `
echo "$1's memory usage : $mem_usage %"

exit 0
