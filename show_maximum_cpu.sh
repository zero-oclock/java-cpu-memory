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

process_top
sort -rn -k 9  top.tmp | grep java |  awk -F ' ' '{print $1 "\t" $9}' | head -5 > top.result
rm -rf top.tmp

#遍历5个进程，获取占用CPU超30%的进程中CPU占用最高的5个线程
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
	jstack $pid | grep -A10 $pid_hex >> cpu_result.log
done < top_Hp.result
