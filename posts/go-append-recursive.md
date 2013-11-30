---
title: go递归函数如何传递数组切片slice
date: '2013-08-18'
description:
categories:
- go
tags:
- go
---


数组切片slice这个东西看起来很美好，真正用起来会发现有诸多的不爽。

第一，数组、数组切片混淆不清，使用方式完全一样，有时候一些特性又完全不一样，搞不清原理很容易误使用。

第二，数组切片的append操作，每次对slice append操作，都返回一个新的slice的引用，对slice的引用没法保持，这样在函数传递slice的情况下append，在调用函数的上下文中看不到slice append的效果。如果想要这种方式凑效，不得不另辟蹊径。本文主要说一下如何解决这个窘境的方法。

函数传递slice存在什么问题？

```
func sliceModify(slice []int) {
	// slice[0] = 88
	slice = append(slice, 6)
}
func main() {
	slice := []int{1, 2, 3, 4, 5}
	sliceModify(slice)
	fmt.Println(slice)
}
```
输出：

```
[1 2 3 4 5]
```
问题所在：

虽然说数组切片在函数传递时是按照引用的语义传递的，比如说在sliceModify函数里面slice[0] = 88，在方法调用的上下文中，调用函数对slice引用的改表是看得见的。

但是在对slice进行append操作的时候，我们惊奇的发现，这次又不管用了。原因就是append操作会返回这个扩展了的slice的引用，必须让原引用重新赋值为新slice的引用，说白了就是，传递过来的这个指针原来指了内存中的A区域，A区域是原数组的真正所在。经过一次 append之后，要把这个指针改为指向B，B对应append后新的slice的引用。但是方法调用的上下文里的slice指针还是指向了老的A内存区域。

这个逻辑实在有些奇葩，这里我不得不再次吐槽append的设计。有人说这个问题好解决啊，只需要在sliceModify函数的返回值中把append后新的slice引用返回就好了。这样做当然是可以滴，但是像递归调用的函数就不好解决了。

下面就说一下这个问题的解决办法，方法也很简单，就是传递指针的指针。虽然有些绕，但是总算把问题解决了。当然也有其他的办法，比如按照java等语言的方式，自己实现一个ArrayList，在对可变数组扩展的时候，千万表改变引用了。

```
func sliceModify(slice *[]int) {
	*slice = append(*slice, 6)
}
func main() {
	slice := []int{1, 2, 3, 4, 5}
	sliceModify(&slice)
	fmt.Println(slice)
}
```
这次就可以输出预期的结果了：

```
[1 2 3 4 5 6]
```
递归调用的例子：

```
func insertTo10(arr *[]int) {
	length := len(*arr)
	if length == 10 {
		return
	}
	*arr = append(*arr, length)
	insertTo10(arr)
}
func main() {
	arr10 := []int{}
	insertTo10(&arr10)
	fmt.Println(arr10)
}
```

