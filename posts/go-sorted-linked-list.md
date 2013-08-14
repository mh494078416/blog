---
title: go实现排序的链表
date: '2013-08-14'
description:
categories:go
tags:go
---

链表的数据结构比较线性数组，优点是 可以方便的对任意的位置进行插入和删除。

这一特性使得它很适合于应用在排序等场景下，由于golang目前类库还不是很完善，在java中可以很简单的使用api提供的支持完成对list或者map的排序，在使用go时就没有那么幸运了，可能需要自己去实现。

下面的例子就是使用go package 中的LinkedList实现的排序的链表。

有几个功能特性：

1.支持固定的长度
2.可自定义排序的规则
3.组合LinkedList功能

```
package codeforfun
import (
	"container/list"
)
type SortedLinkedList struct {
	*list.List
	Limit int
	compareFunc func (old, new interface{}) bool
}
func NewSortedLinkedList(limit int, compare func (old, new interface{}) bool) *SortedLinkedList {
	return &SortedLinkedList{list.New(), limit, compare}
}
func (this SortedLinkedList) findInsertPlaceElement(value interface{}) *list.Element {
	for element := this.Front(); element != nil; element = element.Next() {
		tempValue := element.Value
		if this.compareFunc(tempValue, value) {
			return element
		}
	}
	return nil
}
func (this SortedLinkedList) PutOnTop(value interface{}) {
	if this.List.Len() == 0 {
		this.PushFront(value)
		return
	}
	if this.List.Len() < this.Limit && this.compareFunc(value, this.Back().Value) {
		this.PushBack(value)
		return
	}
	if this.compareFunc(this.List.Front().Value, value) {
		this.PushFront(value)
	} else if this.compareFunc(this.List.Back().Value, value) && this.compareFunc(value, this.Front().Value) {
		element := this.findInsertPlaceElement(value)
		if element != nil {
			this.InsertBefore(value, element)
		}
	}
	if this.Len() > this.Limit {
		this.Remove(this.Back())
	}
}
```
