---
title: go slice和数组的区别
date: '2013-08-17'
description:
categories:go
tags:go
---

1.使用方式

数组和slice长的很像，操作方式也都差不多，并且slice包含了数组的基本的操作方式，如下标、range循环，还有一些如len()则是多种类型共用，所以根据操作根本搞不清数组和切片的区别，能够看出区别的地方主要看如何声明的。

数组的声明方式很单一，通常就是下面这样：

```
array1 := [5]int{1, 2, 3, 4, 5}
array2 := [5]int{}
```
slice的声明方式就非常多样了，如前面介绍的几种：

```
var slice1 = []int{1, 2, 3, 4, 5}
var slice2 = make([]int, 0, 5)
var slice3 = make([]int, 5, 5)
var slice4 = make([]int, 5)
```
加上对数组的切片和append操作都会产生数组切片(slice)


2.值传递or引用传递

```
func arrayModify(array [5]int) {
	newArray := array
	newArray[0] = 88
}
func sliceModify(slice []int) {
	newSlice := slice
	newSlice[0] = 88
}
func main() {
	array := [5]int{1, 2, 3, 4, 5}
	slice := []int{1, 2, 3, 4, 5}
	arrayModify(array)
	sliceModify(slice)
	fmt.Println(array)
	fmt.Println(slice)
}
```
输出

```
[1 2 3 4 5]
[88 2 3 4 5]
```

其实不只是数组，go语言中的大多数类型在函数中当作参数传递都是值语义的。也就是任何值语义的一种类型当作参数传递到调用的函数中，都会经过一次内容的copy，从一个方法栈中copy到另一个方法栈。这对于熟练java的同学需要进行一次彻底的观念转变，在java中除了少数的值类型是按照值传递，所有的类在函数传递时都是具有引用语义的，也就是通过指针传递。所以在使用时传递对象，不需要去分别值和引用。

go说到底不是一种纯粹的面向对象的语言，更多的是一种更简单高效的C，所以在参数传递上跟C保持着基本的一致性。一些较大的数据类型，比如结构体、数组等，最好使用传递指针的方式，这样就能避免在函数传递时对数据的copy。

虽然slice在传递时是按照引用语义传递，但是又因为append()操作的问题，导致即使是引用传递还是不能顺利解决一些问题，后面一篇文章将说明一下如何解决递归函数中传递slice的问题：

[go递归函数如何传递数组切片slice](http://www.codeforfun.info/go/go%E9%80%92%E5%BD%92%E5%87%BD%E6%95%B0%E5%A6%82%E4%BD%95%E4%BC%A0%E9%80%92%E6%95%B0%E7%BB%84%E5%88%87%E7%89%87slice/)
