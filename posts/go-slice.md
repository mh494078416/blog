---
title: go语言中的数组切片slice
date: '2013-08-16'
description:
categories:go 
tags:go
---

初看go语言中的slice，觉得是可变数组的一种很不错的实现，直接在语言语法的层面支持，操作方面比起java中的ArrayList方便了许多。但是在使用了一段时间后，觉得这东西埋的坑不少，使用方式上和arrayList也有很大的不同，在使用时要格外注意。

slice的数据结构
---
首先说一下slice的数据结构，源码可以在google code上找到，[http://code.google.com/p/go/source/browse/src/pkg/runtime/runtime.h](http://code.google.com/p/go/source/browse/src/pkg/runtime/runtime.h)

```
struct Slice
{                          
    byte*   array;	// actual data
    uintgo  len;	// number of elements
    uintgo  cap;	// allocated number of elements
};
```
可以看出主要保存了三个信息：

* 一个指向原生数组的指针
* 元素的个数
* 数组分配的存储空间

slice的基本操作
---
go中生成切片的方式有以下几种，这几种生成方式也对应了对slice的基本操作，每个操作后面go隐藏了很多的细节，如果没有对其足够了解，在使用时很容易被这些坑绊倒。

1.make函数生成

这是最基本，最原始生成slice切片的方式，通过其他方式生成的切片最终也是通过这种方式来完成。因为无论如何都需要填充上面slice结构的三个最基本信息。

通过查找源码，发现最终都是经过下面的c代码实现的：

```
static void makeslice1(SliceType *t, intgo len, intgo cap, Slice *ret)
{
    ret->len = len;
    ret->cap = cap;
    ret->array = runtime·cnewarray(t->elem, cap);
}
```
make函数在生成slice时的写法：

```
var slice1 = make([]int, 0, 5)
var slice2 = make([]int, 5, 5)
// 省略len的写法，len默认等于cap，相当于make([]int, 5, 5)
var slice3 = make([]int, 5)		
```
这个简便的写法实在是有点坑爹，如果你写成make([]int, 5)，go会默认把数组长度len当作slice的容量，按照上面的例子，便生成了这样的结构：`[0 0 0 0 0]`
	
2.对数组进行切片
首先来看下面的代码：

```
arr := [5]int{1, 2, 3, 4, 5}
slice := arr[3 : 5]	//  slice:[4, 5]
slice[0] = 0        // slice:[0, 5]
fmt.Println(slice)
fmt.Println(arr)
```
输出结果：

```
[0 5]
[1 2 3 0 5]
```
从上面可以看出，对数组进行了切片操作，生成的切片里的array指针实际指向了原数组的一个位置，相当于c的代码中对原数组截取生成新的数组[2]arrNew，数组的指针指向arr[3]，所以改变切片里0下标对应元素的值，实际上也就改变了原数组相应数组位置3中元素的值。

关于这个问题这篇博文说的比较详细：[对Go的Slice进行Append的一个“坑”](http://sharecore.info/blog/2013/07/23/the-trap-of-go-slice-appending/)

3.对数组或切片进行append

个人认为这个append是go语言中实现地不太优雅的一个地方，比如对一个slice进行append必须要这样写：`slice = append(slice, 1)`。说白了就是，对一个slice进行append时，必须把新的引用重新赋值给slice。如果只是语法上怪异，那问题还好，只是代码写起来麻烦一点。但是实际情况是这个append操作导致的问题多多，不小心很容易走到append埋的坑里面去。

先来看一个比较奇怪的现象：

```
var sliceA = make([]int, 0, 5)
sliceB := append(sliceA, 1)
fmt.Println(sliceA)
fmt.Println(sliceB)
```
输出结果是：

```
[]
[1]
```
刚看到这样的结果时让人很难以理解，明明声明了容量是5的切片，现在sliceA的len是0，远没有达到切片的容量。按理说对sliceA进行append操作，在没有达到切片容量的情况下根本不需要重新申请一个新的大容量的数组，只需要在原本数组内修改元素的值。而且，go函数在传输切片时是引用传递，这样的话，sliceB和sliceA应该输出一样才对。看到这样的结果，着实让人困惑了很长时间，难道每次append操作都会重新分配数组吗？

答案肯定不是这样的，如果真是这样的话，go也就不用再混了，性能肯定会出问题。下面从go实现append的源码中去找答案，源码位置在：[http://code.google.com/p/go/source/browse/src/pkg/runtime/slice.c](http://code.google.com/p/go/source/browse/src/pkg/runtime/slice.c)
代码很长，这里只截取关键的片段来说明问题：

```
void runtime·appendslice(SliceType *t, Slice x, Slice y, Slice ret)
{
	intgo m = x.len+y.len;
	void *pc;
    if(m > x.cap)
    	growslice1(t, x, m, &ret);
    else
        ret = x;
    // read x[:len]
    if(m > x.cap)
        runtime·racereadrangepc(x.array, x.len*w, pc, runtime·appendslice);
    // read y
    runtime·racereadrangepc(y.array, y.len*w, pc, runtime·appendslice);
    // write x[len(x):len(x)+len(y)]
    if(m <= x.cap)
        runtime·racewriterangepc(ret.array+ret.len*w, y.len*w, pc, runtime·appendslice);
    ret.len += y.len;
    FLUSH(&ret);
}
```
函数定义`appendslice(SliceType *t, Slice x, Slice y, Slice ret)`，对应`slice3 = append(slice1, slice1...)`操作，分别代表：数组里的元素类型、slice1, slice2, slice3。虽然append()语法中，第二个参数不能为slice，但是第二个参数其实是一个可变参数`elems ...Type`，可以传输打散的数组，所以go在处理时同样是转换为slice来操作的。

从上面的代码很清楚的看到，如果x.len + y.len 超过了x.cap，那么就会重新扩展新的切片，如果x.len + y.len还没有超过x.cap，则还是在原切片的数组中进行元素的填充。那么这样跟我们理性的认识是一致的。可以打消掉之前误解的对go append的担心。那问题出在哪呢？

上面忽略了一点，append函数是有go的代码的，不是直接语言级c的实现，在c的实现上还加了go语言自己的处理，在/pkg/builtin/bulitin.go里有函数的定义。这里我只能假设在go的层面对scliceA做了一些隐秘的处理，go如何去调用c的底层实现，我现在还不甚了解，这里也只能分析到这里。以后了解之后再来补充这篇博客，如果有了解的朋友，也非常感激你告诉我。

4.声明无长度的数组 

声明无长度的数组其实就是声明了一个可变数组，也就是slice切片。只不过这个切片的len和cap都是0。这个方法写起来非常方便，如果不了解其背后的实现，那么这样用起来是性能最差的一种。因为会导致频繁的对slice进行重新申请内容的操作，并且需要把，原数组中的元素copy到新的大容量的数组里去。每次重新分配数组容量的步长是len*2，如果进行n次append，那么需要经过log2(n)次的重新申请内存和copy的开销。

后面的一篇文章会继续介绍切片和数组的一些区别:

[go slice和数组的区别](http://www.codeforfun.info/go/go-slice%E5%92%8C%E6%95%B0%E7%BB%84%E7%9A%84%E5%8C%BA%E5%88%AB/)
