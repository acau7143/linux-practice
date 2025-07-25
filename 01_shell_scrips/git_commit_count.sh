#!/bin/bash
start="$1";
curr=$(date +%Y-%m-%d)
curr_y=$(date +%Y)
re='^[0-9]+$'   # 전체 문자열이 숫자로만 이루어져 있는지

if [[ $1 == "" ]]; then
    start="$curr_y-01-01"
    end=$curr
elif ! [[ $1 =~ $re ]]; then
    echo "Please enter a year."
    exit 1
elif [[ ${#start} != 4 ]]; then
    echo "Please enter a year."
    exit 1
else
    end="$start-12-31"
    start="$start-01-01"
fi

echo "$start ~ $end:"

files=$(ls ./)
for i in $files
do
    printf "$i: "
    git rev-list --after=$start --before=$end --count --no-merges HEAD -- "$i"
done | sort -k2 -nr | awk '{printf("%20s %5d\n", $1, $2)}' | nl
