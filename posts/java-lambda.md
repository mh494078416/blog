---
title: java函数式编程之lambda表达式
date: '2013-08-06'
description:
categories:java
tags:java
---
作为比较老牌的面向对象的编程语言java，在对函数式编程的支持上一直不温不火。

认为面向对象式编程就应该纯粹的面向对象，于是经常看到这样的写法：如果你想写一个方法，那么就必须把它放到一个类里面，然后new出来对象，对象调用这个方法。

这种方式在函数式编程语言看来太死板，没有必要在对待多种编程范式上采取非此即彼的做法。

如今比较现代的编程语言也都是多编程范式的支持，不再去对一种编程范式固守一隅，一种语言可能会同时具有面向对象、函数式、元编程等多种特性，这方面java的后来者C#都走在她的前面。

终于在jdk8里发现了lambda表达式的影子，java也开始加入这种函数式编程特性，java码农们终于在之前老土的方法之外有了一种更为简便的选择。

* 首先来看，lambda之前java的做法：
使用匿名内部类：

```
public void testAnonymousClass() {
	Integer[] nums = {2, 5, 1, 6};
	Arrays.sort(nums, new Comparator<Integer>() {
		@Override
		public int compare(Integer o1, Integer o2) {
			if(o1 < o2) 
				return -1;
			return 0;
		}
	});
	for (Integer n : nums) {
		System.out.println(n);
	}
}
```
* 函数式编程语言的做法，这里拿go的代码为例：

```
package main
import (
	"fmt"
)
// 插入排序
func sort(nums []int, compare func (a, b int) int) {
	length := len(nums)
	for i := length - 1; i >= 0; i-- {
		for j := i; j + 1 < length; j++ {
			cur := nums[j]
			next := nums[j + 1]
			if compare(cur, next) > 0 {
				nums[j], nums[j + 1] = next, cur
			}
		}
	}
}
func main() {
	nums := []int{2, 5, 1, 6}
	sort(nums, func(a, b int) int {
			if a > b {
				return 1
			}
			return 0
		})
	fmt.Println(nums)
}
```
go的代码看上去比较长，由于没有像java一样使用类库提供的排序算法，所以go自己实现的插入排序。
这里go语言具有函数里面传函数的能力（也叫高阶函数），所以代码看起来简洁了很多。一般这种场景，函数式编程语言使用匿名函数的方式，在java的看来就必须通过匿名内部类来实现。首先实现一个接口，接口里面定义好方法，匿名内部类实现接口，然后在传入的函数中，通过传递的对象，实现对匿名内部类里的方法的回调。这也就是lambda表达式之前的基本做法。

* lambda表达式是对java实现函数式编程一个取巧方式的补充，下面来看lambda方式的做法：

```
public void testAnonymousClass() {
	Integer[] nums = {2, 5, 1, 6};
	Arrays.sort(nums, (o1, o2) -> {
		if(o1 < o2) 
			return -1;
		return 0;
	});
	for (Integer n : nums) {
		System.out.println(n);
	}
}
```
函数式接口：这是java在解决函数式编程，引入lambda表达式的同时引入的一个概念，具体的意思就是，定义的一个接口，接口里面必须有且只有一个方法，这样的接口就成为函数式接口。
在可以使用lambda表达式的地方，方法声明时必须包含一个函数式的接口。任何函数式接口都可以使用lambda表达式替换。
下面来看lambda的基本逻辑：

```
button.onAction(new EventHandler<ActionEvent>() {
	@Override
	public void handle(ActionEvent e) {
		doSomethingWith(e);
	}
});
```
使用lambda表达式替换：

```
button.onAction((ActionEvent e) -> {
	doSomethingWith(e);
});
```
此lambda表达式的类型可由编译器推断为EventHandler<ActionEvent>，因为onAction()方法采用的对象类型为 EventHandler<ActionEvent>。
由于EventHandler只有一个方法即handle()，此lambda表达式必然是handle()方法的实现。
可以继续简化lambda表达式：

```
button.onAction((e) -> {
	doSomethingWith(e);
});
```
此lambda表达式的参数必须是ActionEvent，因为其类型是由EventHandler接口的 handle()方法指定的。
因此，我们可以简化此lambda表达式，因为其参数类型可以推断。
还可以继续简化：

```
button.onAction(e -> doSomethingWith(e));
```
当lambda表达式只有一个参数且参数类型可以推断时，则不需要括号。
lambda表达式中的代码块只包含一个语句，因此可以去掉大括号和分号。

可以猜测lambda表达式的实现可能是由java编译器在编译java字节码时，会翻译这样的语法糖，最终还是转化为匿名内部类来实现，至少从语义上看来是这样的。那么它究竟怎样做到的，这里的文章可以给出答案：
[和Lambdas的第一次亲密接触](http://developer.51cto.com/art/201302/380803.htm) 

采用的办法是在使用lambda表达式的类中生成一个实例方法，那么当然能够访问到这个类中定义的实例变量、静态变量和公开、私有方法。
那和函数式编程相随相生的闭包问题是否支持了呢？
通过上面的介绍可以看出java对函数式编程的实现，还是主要在编译时对lambda表达式的一些转化，让人看起来像是支持了匿名函数等函数式编程的特性，其实还是使用java自己的一套实现。所以在使用lambda表达式的时候最好头脑清醒，不要纠结是否闭包了。以上谈的是jdk8的预览版本，也可能正式版会做很多的改进，那就不得而知了。
