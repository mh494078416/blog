---
title: 树莓派折腾手记
date: '2013-05-22'
description: play with raspberry pi
categories:
- raspberry
tags:
- raspberry
- linux
---

OS X下通过下面的命令能够把镜像写入SD
------------------------------------
```
unzip 2013-02-09-wheezy-raspbian.zip
df -h
sudo diskutil unmount /dev/rdisk1s1
sudo dd bs=1m if=2013-02-09-wheezy-raspbian.img of=/dev/rdisk1
sudo diskutil eject /dev/rdisk1
```

更换了一个更加快速的源

----------------------
pi的源列表: <http://www.raspbian.org/RaspbianMirrors> 测试了之后发现这个源在国内更新最快 <http://mirror.devunt.kr/raspbian/raspbian/>

更换源：
`sudo vi /etc/apt/sources.list`
更改为：

```
deb http://mirror.devunt.kr/raspbian/raspbian/ wheezy main contrib non-free rpi
```
更新系统:

`sudo apt-get update && sudo apt-get upgrade`

更新固件：

```
$ sudo apt-get install git-core
$ sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
$ sudo rpi-update
```

命令行下显示中文
---------------
`sudo apt-get install ttf-wqy-zenhei`

中文安装完成之后还需要一个输入法：

`sudo apt-get install scim-pinyin`
然后`sudo raspi-config`选择change_locale，
用空格键选择四个中文字体zh_CN.GB2312, zh_CN.GB18030, zh_CN GBK, zh_CN.UTF-8，
选择zh_CN.UTF-8作为系统环境默认区域设置，然后重启

安装需要的软件
-------------
vim
`sudo apt-get install vim`

chrome
`sudo apt-get install chromium-browser chromium-l10n`

远程桌面
`sudo apt-get install xrdp`

通过x2x和Raspberry Pi共享鼠标键盘
<http://blog.xming.me/?p=72>

安装node.js
<http://www.jeremymorgan.com/tutorials/raspberry-pi/how-to-install-node-js-raspberry-pi/>

编译Go语言
<http://dave.cheney.net/2012/09/25/installing-go-on-the-raspberry-pi>

树莓派shell命令
重新配置树莓派：`sudo raspi-config`

查看cpu温度：`cat /sys/class/thermal/thermal_zone0/temp`

配置无线网络和固定ip
--------------------
命令查看USB设备列表`lsusb`

扫描无线网络`sudo iwlist wlan0 scan`

```
$ sudo vim /etc/wpa.conf
    network={
	ssid="TP-LINK_B3A8BC"
	proto=RSN
	key_mgmt=WPA-PSK
	pairwise=CCMP TKIP
	group=CCMP TKIP
	psk="password"
	}
$ sudo vim /etc/network/interfaces
    auto lo
	iface lo inet loopback
	iface eth0 inet dhcp
	allow-hotplug wlan0
	iface wlan0 inet manual
	wpa-roam /etc/wpa.conf
	address 192.168.1.109
	netmask 255.255.255.0
	network 192.168.1.0
	broastcast 192.168.1.255
	gateway 192.168.1.1
	iface default inet dhcp
$ sudo ifdown wlan0
$ sudo ifup wlan0
$ iwconfig
```

安装samba
------------
```
sudo apt-get install samba
sudo cp /etc/samba/smb.conf  /etc/samba/smb.conf.bak
sudo vim /etc/samba/smb.conf
```
配置security = user

配置共享位置，在文件末添加：

```
[media]
comment = pi sd card
path = /home/pi/samba
valid users = @users
force group = users
create mask = 0660
directory mask = 0771
read only = no
```
重启samba
sudo service samba restart
windows下，在运行里面:\\:[树莓派ip]访问，
macox在safari里访问 smb://[树莓派ip]

媒体播放
-------
使用方法：在终端用命令打开：omxplayer + 文件名，如果用HDMI接口的音频输出的话要加上-o hdmi参数

```
Key    Action
1    　　加速
2    　　减速
j    　　上一条音轨
k    　　下一条音轨
i    　　上一节
o    　　下一节
n    　　上一条字幕轨
m    　　下一条字幕轨
s    　　显示/不显示字幕
q    　　退出
空格或p　　暂停/继续
-    　　减小音量
+    　　增加音量
左    　　后退30
右    　　前进30
上    　　后退600
下    　　前进600
```

树莓派的应用
-----------
Hacking a Raspberry Pi into a wireless airplay speaker
<http://jordanburgess.com/post/38986434391/raspberry-pi-airplay>

超频的玩法
<http://www.oschina.net/translate/how-to-overclock-raspberry-pi>

<http://jade.is-programmer.com/posts/36984.html>

<http://www.memetic.org/raspberry-pi-overclocking/>

启动配置项说明
<http://elinux.org/RPiconfig>

很强大的玩法，树莓派集群
<http://www.southampton.ac.uk/~sjc/raspberrypi/pi_supercomputer_southampton.htm>

rpi-update更新firmware
----------------------
```
sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
sudo apt-get install ca-certificates
sudo apt-get install git-core
sudo rpi-update
sudo reboot
```

更多参考：

	<http://blog.sina.com.cn/s/blog_3cb6a78c0101a0fe.html>
	<http://hi.baidu.com/nonezk/item/e2c82a03683e2c95a3df4344>
	<http://blog.linguofeng.com/archive/2013/04/04/raspberry-pi.html>
	<http://www.leiphone.com/raspberry-pi-hands-on.html>
	
在一张SD卡上安装多个系统
-----------------------
<http://www.berryterminal.com/doku.php/berryboot#adding_your_own_custom_operating_systems_to_the_menu>

使用ssh远程切换berryboot默认系统

<http://rvalbuena.blogspot.com/2013/02/changing-berryboot-selected-os-on.html>

用树莓派搭建独立博客
-------------------
使用disqus，增加评论功能
<http://disqus.com>
可以参考的静态博客网站
在Pi和Github上搭建自己的个人博客

gor:

<https://github.com/wendal/gor>

<http://defworld.com/2013-05/build-your-blog-with-gor-and-pi.html>

Jekyll:	

<http://blog.huatai.me/2013/04/18/using-jekyll.html>

<http://www.soimort.org/posts/101/>

ruhoh：

<http://ruhoh.com/>

在路由器上搭建博客

<http://blog.huatai.me/2013/01/24/how-this-blog-relive.html>

挂载移动硬盘
------------
lsusb查看是否能找到移动硬盘的硬件

ls -l /dev/查看sda开头的设备

首先安装ntfs-3g

```sudo apt-get install ntfs-3g```

```sudo mount -t ntfs -o utf-8 /dev/sda5 /mnt/sda5```

sda5是取决于你的实际情况，a表示第一个硬盘，5表示第5个分区。
-t ntfs以ntfs文件格式挂载
-o utf-8 设置文件编码
开机自动挂载硬盘
把上述的命令写入 /etc/fstab 文件中`cat /etc/fstab`

```
proc            /proc           proc    defaults          0       0
#Handled by Berryboot 
#/dev/mmcblk0p1  /boot           vfat    defaults          0       2
#/dev/mmcblk0p2  /               ext4    defaults,noatime  0       1
/dev/sda5	/mnt/sda5	ntfs-3g	utf-8,noexec,umask=0000	0	0
```

开机启动脚本
-----------
在/etc/init.d/ 下新建svnserve，新建完成后：sudo chmod +x svnserve，加可执行权限

```
#!/bin/bash
# description: script to start/stop svnserve
case $1 in
	start)
		svnserve -d -r /home/pi/svn_repository
		;;
	stop)
		killall svnserve
		;;
*)
echo "Usage: $0 (start|stop)"
;;
esac
```
