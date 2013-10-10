---
title: os x10.9源码编译升级svn1.8
date: '2013-10-10'
description:
categories:
- mac
tags:
- os x
- mac
- svn
---

之前升级了开发者预览版的冲浪胜地os x 10.9，发现xcode里command line tools附带的svn版本是1.7，自己很多的代码工程都是svn1.8的版本，所以需要升级svn版本到1.8。但是尝试了几种方法，发现并不是很容易，折腾了几个小时的时间，下面把过程记录如下，方便后来者。

首先想到的是，升级最新的xcode5.0，这样就可以使用最新的command line tools，开始时，这种方法是凑效的，升级xcode5.0后， svn确实是1.8了。但是过了没多久，系统提示升级xcode，升级之后发现，svn版本又退回到1.7。在尝试升级command line tools无果，所以尝试别的办法。

从subversion官网下载二进制的安装包，但是只有os x 10.8的，安装到一半继续不下去，此路也不通。

最后尝试svn源码编译，步骤如下：

1. 从[官网](http://subversion.apache.org/download/)下载subversion-1.8.3.tar.gz（zip的试过不行），然后`tar -xvf subversion-1.8.3`解压缩。
2. 编译源码

```
cd subversion-1.8.3
./configure --with-ssl
make
sudo make install
```
3. 建立软链接

```
cd /usr/bin
sudo ln -s ~/subversion-1.8.3/subversion/svn svn
```
