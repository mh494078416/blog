---
title: 函数式编程语言的柯里化含义
date: '2014-07-07'
description: 函数是编程语言的柯里化含义
categories:
- scala
tags:
- scala

---

函数式编程语言的几个特征中比较难于理解的就是柯里化了，下面一个简单的例子帮助理解一下，一句话概括的话就是:

> 柯里化使函数式编程语言具有动态创建函数的能力。

```
// 普通过程式编程语言的写法
def fn1(x: Int, y: Int) = x + y
// 函数式编程语言的写法
def fn2(x: Int)(y: Int) = x + y

fn1(1, 2)
fn2(1)(2)

// 但是函数式编程语言具有柯里化的特性，允许动态的创建一个函数，比如
var add10 = fn2(10)(_)
add10(3)

// 函数式编程的柯里化其实相当于实现了数学公式：fa(x, y) = fb(x)(y)，把函数fa拆解成两个函数fb(x)和fb(x)(y)
```

output:

```
scala> def fn1(x: Int, y: Int) = x + y
fn1: (x: Int, y: Int)Int

scala> def fn2(x: Int)(y: Int) = x + y
fn2: (x: Int)(y: Int)Int

scala> fn1(1, 2)
res43: Int = 3

scala> fn2(1)(2)
res44: Int = 3

scala> var add10 = fn2(10)(_)
add10: Int => Int = <function1>

scala> add10(3)
res45: Int = 13
```
