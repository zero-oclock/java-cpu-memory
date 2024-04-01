#!/bin/bash

while true

do

pid=`ps -ef | grep UploadObject | grep -v grep | awk '{print $2}'`

if [ -z "$pid" ]; then
echo "#pid为空"
else
echo "#pid不为空"
pidstat -w -p $pid 1 1000
break
fi

sleep 0.08

done
