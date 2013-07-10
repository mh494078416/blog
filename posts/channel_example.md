---
title: go语言channel的别样用法
date: '2013-07-10'
description:
categories:
- Go
tags:
- Go
- channel
-并发
---

1.返回值使用通道

```
func main() {
	// 生成随机数作为一个服务
	randService := randGenerator()
	// 从服务中读取随机数并打印
	fmt.Printf("%d\n",<-randService)
}
func randGenerator() chan int {
	// 创建通道
	out := make(chan int)
	// 创建协程
	go func() {
		for {
			//向通道内写入数据，如果无人读取会等待
			out <- rand.Int()
		}
	}()
	return out
}
```
2.参数使用通道

```
//一个查询结构体
type query struct {
	//参数Channel
	sql chan string
	//结果Channel
	result chan string
}
//执行Query
func execQuery(q query) {
	//启动协程
	go func() {
		//获取输入
		sql := <-q.sql
		//访问数据库，输出结果通道
		q.result <- "get" + sql
	}()
}
func main() {
	//初始化Query
	q := query{make(chan string, 1),make(chan string, 1)}
	//执行Query，注意执行的时候无需准备参数
	execQuery(q)
	//准备参数
	q.sql <- "select * from table"
	//获取结果
	fmt.Println(<-q.result)
}
```
3.并发循环

```
func doSomething(num int) (sum int) {
	for i := 1; i <= 10; i++ {
		fmt.Printf("%d + %d = %d\n", num, num + i, num + num + i)
		sum = sum + num + i
	}
	return sum
}
func testLoop() {
	// 建立计数器，通道大小为cpu核数
	var NumCPU = runtime.NumCPU()
	fmt.Printf("NumCPU = %d\n", NumCPU)
	sem :=make(chan int, NumCPU);
	//FOR循环体
	data := []int{1, 11, 21, 31, 41, 51, 61, 71, 81, 91}
	for _,v:= range data {
		//建立协程
		go func (v int) {
			fmt.Printf("doSomething(%d)...\n", v)
			sum := doSomething(v);
			//计数
			sem <- sum;
		} (v);
	}
	// 等待循环结束
	var total int = 0
	for i := 0; i < len(data); i++ {
		temp := <- sem
		fmt.Printf("%d <- sem\n", temp)
		total = total + temp
	}
	fmt.Printf("total = %d\n", total)
}
func main() {
	testLoop()
}
```

4.利用channel计算素数

```
// Send the sequence 2, 3, 4, ... to channel 'in'.
func Generate(ch chan int) {
	for i := 2; ; i++ {
		ch<- i // Send 'i' to channel 'in'.
	}
}
// Copy the values from channel 'in' to channel 'out',
// removing those divisible by 'prime'.
func Filter(in chan int, out chan int, prime int) {
	for {
		i := <-in // Receive valuefrom 'in'.
		if i%prime != 0 {
			out <- i // Send'i' to 'out'.
		}
	}
}
func main() {
	in := make(chan int)
	go Generate(in)      // Launch Generate goroutine.
	for i := 0; i < 100; i++ {
		prime := <-in
		print(prime, "\n")
		out := make(chan int)
		go Filter(in, out, prime)
		in = out
	}
}
```
5.共享变量的读写

```
//共享变量有一个读通道和一个写通道组成
type shardedVar struct {
	reader chan int
	writer chan int
}
//共享变量维护协程
func whachdog(v shardedVar) {
	go func() {
		//初始值
		var value int = 0
		for {
			//监听读写通道，完成服务
			select {
			case value = <-v.writer:
			case v.reader <-value:
			}
		}
	}()
}
func main() {
	//初始化，并开始维护协程
	v := shardedVar{make(chan int), make(chan int)}
	whachdog(v)
	//读取初始值
	fmt.Println(<-v.reader)
	//写入一个值
	v.writer <- 1
	//读取新写入的值
	fmt.Println(<-v.reader)
}
```
