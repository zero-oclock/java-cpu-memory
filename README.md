# java-cpu-memery
- 执行show_maximum_cpu.sh脚本，输出高CPU占用率的线程堆栈信息
- 执行show_maximum_memery.sh脚本，输出高内存占用率的线程堆栈信息

## 一、CPU占用率分析（定位到线程堆栈）
1. 赋予脚本执行权限  
- chmod +x show_maximum_cpu.sh
2. 运行CPU分析脚本  
- 输入命令: sh show_maximum_cpu.sh [进程占用率] [线程占用率]
```
  执行结果:  
     分析CPU占用最高的5个进程，取其中占用率超过30%的进程:  
     进程:16495    负载:212.5%  大于30%  
     进程:14670    负载:6.2%  小于30%，无需排查  
     进程:7750    负载:0.0%  小于30%，无需排查  
     进程:7210    负载:0.0%  小于30%，无需排查  
     进程:5779    负载:0.0%  小于30%，无需排查  

     分析CPU占用率超过30%的进程，其中CPU占用率超过20%的线程:  
     进程:16495    线程:16581  负载:99.9%  大于20%  
     进程:16495    线程:16577  负载:99.9%  大于20%  
     线程:16495    负载:6.7%  小于20%，无需排查  
     线程:16495    负载:0.0%  小于20%，无需排查  
     线程:16495    负载:0.0%  小于20%，无需排查  
     
     请打开cpu_result.log文件查看CPU高负载堆栈信息
```
3. 打开分析结果文件（高CPU堆栈信息）  
- 输入命令: less cpu_result.log
```
     >>>>>>>>>>>>>>>>高CPU线程(99.9%):  
     "org.springframework.kafka.KafkaListenerEndpointContainer#4-9-C-1" #80 prio=5 os_prio=0 tid=0x00007f5d15210800 nid=0x40c5 runnable [0x00007f5c834a9000]  
     java.lang.Thread.State: RUNNABLE  
        at sun.nio.ch.EPollArrayWrapper.epollWait(Native Method)  
        at sun.nio.ch.EPollArrayWrapper.poll(EPollArrayWrapper.java:269)  
        at sun.nio.ch.EPollSelectorImpl.doSelect(EPollSelectorImpl.java:93)  
        at sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:86)  
        - locked <0x00000000f2ca93a8> (a sun.nio.ch.Util$3)  
        - locked <0x00000000f2ca9398> (a java.util.Collections$UnmodifiableSet)  
        - locked <0x00000000f2ca9150> (a sun.nio.ch.EPollSelectorImpl)  
        at sun.nio.ch.SelectorImpl.selectNow(SelectorImpl.java:105)  
        at org.apache.kafka.common.network.Selector.select(Selector.java:672)  
        at org.apache.kafka.common.network.Selector.poll(Selector.java:396)  
        at org.apache.kafka.clients.NetworkClient.poll(NetworkClient.java:460)  
        at org.apache.kafka.clients.consumer.internals.ConsumerNetworkClient.poll(ConsumerNetworkClient.java:258)  
        at org.apache.kafka.clients.consumer.internals.ConsumerNetworkClient.poll(ConsumerNetworkClient.java:230)  
        at org.apache.kafka.clients.consumer.KafkaConsumer.pollOnce(KafkaConsumer.java:1164)  
        at org.apache.kafka.clients.consumer.KafkaConsumer.poll(KafkaConsumer.java:1111)  
        at org.springframework.kafka.listener.KafkaMessageListenerContainer$ListenerConsumer.run(KafkaMessageListenerContainer.java:654)  
        at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)  
        at java.util.concurrent.FutureTask.run(FutureTask.java:266)  
        at java.lang.Thread.run(Thread.java:745)  
```
