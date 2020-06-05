# java-cpu-memery
- A script that can quickly locate CPU and memory problems on the Java line（一个可以快速定位Java线上CPU和内存问题的脚本）

# 即使CPU占用分析
1. 赋予脚本执行权限  
   chmod +x show_maximum_cpu.sh
2. 运行CPU分析脚本  
   sh show_maximum_cpu.sh  
   ![执行脚本打印](https://github.com/linjunbo/java-cpu-memery/blob/master/show_maximum_cpu.png)
3. 打开分析结果文件（高CPU堆栈信息）  
   less cpu_result.log
