---
title: goʵ�����������
date: '2013-08-14'
description:
categories:go
tags:go
---

��������ݽṹ�Ƚ��������飬�ŵ��� ���Է���Ķ������λ�ý��в����ɾ����

��һ����ʹ�������ʺ���Ӧ��������ȳ����£�����golangĿǰ��⻹���Ǻ����ƣ���java�п��Ժܼ򵥵�ʹ��api�ṩ��֧����ɶ�list����map��������ʹ��goʱ��û����ô�����ˣ�������Ҫ�Լ�ȥʵ�֡�

��������Ӿ���ʹ��ǰһƪ�����е�LinkedListʵ�ֵ����������

�м����������ԣ�

1.֧�̶ֹ��ĳ���
2.���Զ�������Ĺ���
3.���LinkedList����

```
package codeforfun
type SortedLinkedList struct {
	*LinkedList
	Limit int
	compareFunc func (old, new interface{}) bool
}
func NewSortedLinkedList(limit int, compare func (old, new interface{}) bool) *SortedLinkedList {
	return &SortedLinkedList{NewLinkedList(), limit, compare}
}
func (this SortedLinkedList) findInsertPlaceElement(value interface{}) *Element {
	for element := this.Head(); element != nil; element = element.Next() {
		tempValue := element.Value
		if this.compareFunc(tempValue, value) {
			return element
		}
	}
	return nil
}
func (this SortedLinkedList) PutOnTop(value interface{}) {
	if this.length == 0 {
		this.PushHead(value)
		return
	}
	if this.length < this.Limit && this.compareFunc(value, this.Tail().Value) {
		this.PushTail(value)
		return
	}
	if this.compareFunc(this.Head().Value, value) {
		this.PushHead(value)
	} else if this.compareFunc(this.Tail().Value, value) && this.compareFunc(value, this.Head().Value) {
		element := this.findInsertPlaceElement(value)
		if element != nil {
			this.InsertBefore(value, element)
		}
	}
	if this.length > this.Limit {
		this.remove(this.Tail())
	}
}
```
