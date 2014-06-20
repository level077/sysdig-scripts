description
---------------------
   sysdig小脚本

net_rt
---------------------
* 计算网络调用的响应时间，如http  mysql  memcache等
* 使用: sysdig -c net_rt "port min_msec"
  * port: 端口
  * min_msec: 最低响应时间，若请求大于这个时间，以红色字体输出，否则蓝色字体
* 计算方法：取发送和接收两个系统调用之间的时间差，如sendto与recvfrom之间的差值(不局限于这两个系统调用，以evt.is_read作为判断标准)。注：这里以第一次接收响应时的时间作为请求结束时间。
