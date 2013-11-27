---
title: 记openJDK里踩过的一坑
date: '2012-05-26'
description:
categories:
- 坑
tags:
- 坑
- openJDK
---

自己开发机器使用的是orcale官方jdk，在本地调试ok的代码，发到厂里线上的机器，采用的openjdk的版本，发现如何调试都不通。不同jdk对同样代码采用不同的处理方式，踩进这样的坑里，着实蛋疼，排查也很难想到在这里会出问题。最后发现有问题的是以下代码，因为jdk版本的不同，内部采用排序的实现方式不一样，导致输出不一样的结果。

```
public static void main(String [] args) {
	List<Integer> list = new ArrayList<Integer>();
	list.add(5);
	list.add(7);
	list.add(3);
	Collections.sort(list , new Comparator<Integer>() {
		@Override
		public int compare(Integer o1, Integer o2) {
			return o1 - o2 > 0 ? -1 : 0;
		}
	});
	System.out.println(list);
	
}
```

在orcale jdk里，上面代面是能够按照预期正确排序的，输出结果：`[7, 5, 3]`

open jdk里，输出结果：	`[5, 7, 3]`

原因在于`Comparator`对`compare`方法返回值的处理上。

保险的做法是把`o1 - o2 > 0 ? -1 : 0`改为`o1 - o2 > 0 ? (o1 - o2 < 0 ? 1 : 0)`
