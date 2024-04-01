#!/bin/bash

while true

do

pid=`ps -ef | grep UploadObject | grep -v grep | awk '{print $2}'`

if [ -z "$pid" ]; then
echo "#pid为空"
else
echo "#pid="$pid
pidstat -p $pid -t -w 1 1000
break
fi

sleep 0.08

done
