p_threshold=$1
t_threshold=$2
if [ ! -n "$p_threshold" ];then
	p_threshold=30
fi
if [ ! -n "$t_threshold" ];then
	t_threshold=20
fi

#初始化文件
rm -rf cpu_result.log
rm -rf top_Hp.result
rm -rf top.tmp

#获取CPU占用最高的5进程
top -b -n 1 -d 3 > top.tmp

process_top() {
	start=0
	while read -r line
	do
        	start=`expr $start + 1`
        	if [[ $line =~ "PID" ]] && [[ $line =~ "CPU" ]] && [[ $line =~ "MEM" ]]; then
                	break
        	fi
	done < top.tmp
	sed -i "1,${start}d" top.tmp
}

process_stack() {
	nid=$1
	index=0
	start=0
	while read -r line
	do
		index=`expr $index + 1`
		if [[ $start -eq 0 ]] && [[ $line =~ "prio=" ]] && [[ $line =~ "tid=" ]] && [[ $line =~ "nid=" ]] && [[ ! $line =~ "nid=$nid" ]]; then
                        start=$index
                fi
	done < cpu_result_tmp.log
	sed -i "${start},${index}d" cpu_result_tmp.log
}

process_top
sort -rn -k 9  top.tmp | grep java |  awk -F ' ' '{print $1 "\t" $9}' | head -5 > top.result
rm -rf top.tmp

#遍历5个进程，获取占用CPU超30%的进程中CPU占用最高的5个线程
echo -e "\n \e[1;33;41m 分析CPU占用最高的5个进程，取其中占用率超过${p_threshold}%的进程: \e[0m"
while read -r line
do
	pid=`echo $line | awk -F ' ' '{print $1}'`
	cpu_load=`echo $line | awk -F ' ' '{print $2}'`
	compare=`awk -v num1=$cpu_load -v num2=$p_threshold 'BEGIN{print(num1>num2)?"1":"0"}'`
	if [ $compare -le 0 ]; then
		echo "进程:${pid}    负载:${cpu_load}%  小于${p_threshold}%，无需排查"
		continue
	fi
	echo "进程:${pid}    负载:${cpu_load}%  大于${p_threshold}%"
	top -Hp $pid -b -n 1 -d 3 > top.tmp
	process_top
	sort -rn -k 9  top.tmp | grep java |  awk -F ' ' '{print $1 "\t" $9}' | head -5 > top_Hp_tmp.result
	rm -rf top.tmp
	sed -i "s/^/$pid   &/g" top_Hp_tmp.result
	cat top_Hp_tmp.result >> top_Hp.result
	rm -rf top_Hp_tmp.result
done < top.result

#打印出占用CPU最高的5个线程中CPU占用超过20%的线程
echo -e "\n \e[1;33;41m 分析CPU占用率超过${p_threshold}%的进程，其中CPU占用率超过${t_threshold}%的线程: \e[0m"
touch top_Hp.result
while read -r line
do
	pid=`echo $line | awk -F ' ' '{print $1}'`
	tid=`echo $line | awk -F ' ' '{print $2}'`
        cpu_load=`echo $line | awk -F ' ' '{print $3}'`
	compare=`awk -v num1=$cpu_load -v num2=$t_threshold 'BEGIN{print(num1>num2)?"1":"0"}'`
        if [ $compare -le 0 ]; then
                echo "线程:${pid}    负载:${cpu_load}%  小于${t_threshold}%，无需排查"
                continue
        fi
	echo "进程:${pid}    线程:${tid}  负载:${cpu_load}%  大于${t_threshold}%"
	pid_hex=`printf "%x\n" $tid`
	pid_hex="0x"${pid_hex}
	echo -e ">>>>>>>>>>>>>>>>高CPU线程:" >> cpu_result.log
	jstack $pid | grep -A200 $pid_hex >> cpu_result_tmp.log
	process_stack $pid_hex
	cat cpu_result_tmp.log >> cpu_result.log
	rm -rf cpu_result_tmp.log
done < top_Hp.result

echo -e "\n\n请打开cpu_result.log文件查看CPU高负载堆栈信息\n\n"
