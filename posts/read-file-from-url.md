---
title: 读取网络上文件到内存
date: '2011-12-19'
description:
categories:
- code
- java
tags:
- code
- java
---

从网络上下载文件到硬盘相对简单，拿到文件输出流，网络上的输入流，一边读输入流一边写输出流，都读取完毕，关掉输入、输出流就好。
但是读取网络上的文件到内存，由于不知道网络上文件的具体大小，没法申请一个准确的byte数组大小。而且读取网络上的输入流时，是不知道一次能读到的数据包的大小的，必须一点点的读取保存，又涉及byte数组的重新申请，和最后resize一个合适的byte[]，相对麻烦一些，把自己写的一小段代码记录在此，方便日后的使用。

```
public byte[] readBytesFromUrl(String urlStr, int initLength) {
		if (initLength == 0) {
			return null;
		}
		try {
			URL url = new URL(urlStr);
			URLConnection conn = url.openConnection();
			InputStream inputStream = conn.getInputStream();
			byte[] buffer = new byte[initLength];
			byte[] temp = new byte[1024];
			int bytesum = 0;
			int byteread = 0;
			while ((byteread = inputStream.read(temp)) != -1) {
				for (int i = 0; i < byteread; i++) {
					int index = bytesum + i;
					if (index == buffer.length) {
						byte[] newBuffer = new byte[buffer.length + initLength];
						for (int j = 0; j < buffer.length; j++) {
							newBuffer[j] = buffer[j];
						}
						buffer = newBuffer;
					}
					buffer[index] = temp[i];
				}
				bytesum += byteread;
			}
			if (buffer.length > bytesum) {
				byte[] newBuffer = new byte[bytesum];
				for (int i = 0; i < bytesum; i++) {
					newBuffer[i] = buffer[i];
				}
				buffer = newBuffer;
			}
			return buffer;
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
```

