---
title: Go实现的双向链表
date: '2013-08-14'
description:
categories:go
tags:go
---

* 基本上就是把数据结构中学习的c的双向链表用go来重写了一遍

```
package codeforfun
// List中的单个元素
type Element struct {
	// 前后指针
	next,  prev *Element
	// 包含的实际值
	Value interface{}
}
type LinkedList struct {
	// 头指针, 尾指针
	head,  tail *Element
	length         int
}
// 创建List
func NewLinkedList() *LinkedList {
	linkedList := new(LinkedList)
	return linkedList
}
func (l *LinkedList) Head() *Element { return l.head }
func (l *LinkedList) Tail() *Element { return l.tail }
func (e *Element) Next() *Element { return e.next }
func (e *Element) Prev() *Element { return e.prev }
func (l *LinkedList) Remove(e *Element) interface{} {
	l.remove(e)
	return e.Value
}
// 执行实际的删除操作
func (l *LinkedList) remove(e *Element) {
	if e.prev == nil {
		// 如果e处于链表的开头, 将链表的头指针指向e的下一个Element
		l.head = e.next
	} else {
		// 将e的前一个Element的next指针指向e的后一个Element
		e.prev.next = e.next
	}
	if e.next == nil {
		// 如果e处于链表的末尾, 将链表的尾指针指向e的前一个Element
		l.tail = e.prev
	} else {
		// 将e的后一个Element的prev指针指向e的前一个Element
		e.next.prev = e.prev
	}
	e.prev = nil
	e.next = nil
	l.length--
}
// 在mark之前插入e
func (l *LinkedList) insertBefore(e *Element, mark *Element) {
	if mark.prev == nil {
		// 头指针指向e
		l.head = e
	} else {
		// 将mark的前一个Element的next指针指向e
		mark.prev.next = e
	}
	// 调整e和mark的前后指针
	e.prev = mark.prev
	mark.prev = e
	e.next = mark
	l.length++
}
// 在mark之后插入e
func (l *LinkedList) insertAfter(e *Element, mark *Element) {
	if mark.next == nil {
		// 尾指针指向e
		l.tail = e
	} else {
		// 将mark的后一个Element的prev指针指向e
		mark.next.prev = e
	}
	// 调整e和mark的前后指针
	e.next = mark.next
	mark.next = e
	e.prev = mark
	l.length++
}
// 在链表的开头插入e
func (l *LinkedList) insertFront(e *Element) {
	if l.head == nil {
		// 空链表单独处理
		l.head, l.tail = e, e
		e.prev, e.next = nil, nil
		l.length = 1
		return
	}
	l.insertBefore(e, l.head)
}
// 在链表的末尾插入e
func (l *LinkedList) insertBack(e *Element) {
	if l.tail == nil {
		// 空链表单独处理
		l.head, l.tail = e, e
		e.prev, e.next = nil, nil
		l.length = 1
		return
	}
	l.insertAfter(e, l.tail)
}
// 将Value包装成Element, 并将Element插入链表开头
func (l *LinkedList) PushHead(Value interface{}) *Element {
	e := &Element{nil, nil, Value}
	l.insertFront(e)
	return e
}
// 将Value包装成Element, 并将Element插入链表末尾
func (l *LinkedList) PushTail(Value interface{}) *Element {
	e := &Element{nil, nil, Value}
	l.insertBack(e)
	return e
}
// 将Value包装成Element, 并将Element插入mark之前
func (l *LinkedList) InsertBefore(Value interface{}, mark *Element) *Element {
	e := &Element{nil, nil, Value}
	l.insertBefore(e, mark)
	return e
}
// 将Value包装成Element, 并将Element插入mark之后
func (l *LinkedList) InsertAfter(Value interface{}, mark *Element) *Element {
	e := &Element{nil, nil, Value}
	l.insertAfter(e, mark)
	return e
}
// 将e移动到链表的开头
func (l *LinkedList) MoveToFront(e *Element) {
	if l.head == e {
		return
	}
	// 先将e删除, 然后在链表开头插入
	l.remove(e)
	l.insertFront(e)
}
// 将e移动到链表的末尾
func (l *LinkedList) MoveToBack(e *Element) {
	if l.tail == e {
		return
	}
	// 先将e删除, 然后在链表末尾插入
	l.remove(e)
	l.insertBack(e)
}
// 将ol整体插入链表的开头
func (l *LinkedList) PushFrontList(ol *LinkedList) {
	first := ol.Head()
	// 从ol的尾部开始, 依次将ol的每个Value插入链表的开头
	for e := ol.Tail(); e != nil; e = e.Prev() {
		l.PushHead(e.Value)
		if e == first {
			break
		}
	}
}
// 将ol整体插入链表的末尾
func (l *LinkedList) PushBackList(ol *LinkedList) {
	last := ol.Tail()
	// 从ol的头部开始, 依次将ol的每个Value插入链表的末尾
	for e := ol.Head(); e != nil; e = e.Next() {
		l.PushTail(e.Value)
		if e == last {
			break
		}
	}
}
func (l *LinkedList) Len() int { return l.length }
```
