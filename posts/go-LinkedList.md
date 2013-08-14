---
title: Goʵ�ֵ�˫������
date: '2013-08-14'
description:
categories:go
tags:go
---

* �����Ͼ��ǰ����ݽṹ��ѧϰ��c��˫��������go����д��һ��

```
package codeforfun
// List�еĵ���Ԫ��
type Element struct {
	// ǰ��ָ��
	next,  prev *Element
	// ������ʵ��ֵ
	Value interface{}
}
type LinkedList struct {
	// ͷָ��, βָ��
	head,  tail *Element
	length         int
}
// ����List
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
// ִ��ʵ�ʵ�ɾ������
func (l *LinkedList) remove(e *Element) {
	if e.prev == nil {
		// ���e��������Ŀ�ͷ, �������ͷָ��ָ��e����һ��Element
		l.head = e.next
	} else {
		// ��e��ǰһ��Element��nextָ��ָ��e�ĺ�һ��Element
		e.prev.next = e.next
	}
	if e.next == nil {
		// ���e���������ĩβ, �������βָ��ָ��e��ǰһ��Element
		l.tail = e.prev
	} else {
		// ��e�ĺ�һ��Element��prevָ��ָ��e��ǰһ��Element
		e.next.prev = e.prev
	}
	e.prev = nil
	e.next = nil
	l.length--
}
// ��mark֮ǰ����e
func (l *LinkedList) insertBefore(e *Element, mark *Element) {
	if mark.prev == nil {
		// ͷָ��ָ��e
		l.head = e
	} else {
		// ��mark��ǰһ��Element��nextָ��ָ��e
		mark.prev.next = e
	}
	// ����e��mark��ǰ��ָ��
	e.prev = mark.prev
	mark.prev = e
	e.next = mark
	l.length++
}
// ��mark֮�����e
func (l *LinkedList) insertAfter(e *Element, mark *Element) {
	if mark.next == nil {
		// βָ��ָ��e
		l.tail = e
	} else {
		// ��mark�ĺ�һ��Element��prevָ��ָ��e
		mark.next.prev = e
	}
	// ����e��mark��ǰ��ָ��
	e.next = mark.next
	mark.next = e
	e.prev = mark
	l.length++
}
// ������Ŀ�ͷ����e
func (l *LinkedList) insertFront(e *Element) {
	if l.head == nil {
		// ������������
		l.head, l.tail = e, e
		e.prev, e.next = nil, nil
		l.length = 1
		return
	}
	l.insertBefore(e, l.head)
}
// �������ĩβ����e
func (l *LinkedList) insertBack(e *Element) {
	if l.tail == nil {
		// ������������
		l.head, l.tail = e, e
		e.prev, e.next = nil, nil
		l.length = 1
		return
	}
	l.insertAfter(e, l.tail)
}
// ��Value��װ��Element, ����Element��������ͷ
func (l *LinkedList) PushHead(Value interface{}) *Element {
	e := &Element{nil, nil, Value}
	l.insertFront(e)
	return e
}
// ��Value��װ��Element, ����Element��������ĩβ
func (l *LinkedList) PushTail(Value interface{}) *Element {
	e := &Element{nil, nil, Value}
	l.insertBack(e)
	return e
}
// ��Value��װ��Element, ����Element����mark֮ǰ
func (l *LinkedList) InsertBefore(Value interface{}, mark *Element) *Element {
	e := &Element{nil, nil, Value}
	l.insertBefore(e, mark)
	return e
}
// ��Value��װ��Element, ����Element����mark֮��
func (l *LinkedList) InsertAfter(Value interface{}, mark *Element) *Element {
	e := &Element{nil, nil, Value}
	l.insertAfter(e, mark)
	return e
}
// ��e�ƶ�������Ŀ�ͷ
func (l *LinkedList) MoveToFront(e *Element) {
	if l.head == e {
		return
	}
	// �Ƚ�eɾ��, Ȼ��������ͷ����
	l.remove(e)
	l.insertFront(e)
}
// ��e�ƶ��������ĩβ
func (l *LinkedList) MoveToBack(e *Element) {
	if l.tail == e {
		return
	}
	// �Ƚ�eɾ��, Ȼ��������ĩβ����
	l.remove(e)
	l.insertBack(e)
}
// ��ol�����������Ŀ�ͷ
func (l *LinkedList) PushFrontList(ol *LinkedList) {
	first := ol.Head()
	// ��ol��β����ʼ, ���ν�ol��ÿ��Value��������Ŀ�ͷ
	for e := ol.Tail(); e != nil; e = e.Prev() {
		l.PushHead(e.Value)
		if e == first {
			break
		}
	}
}
// ��ol������������ĩβ
func (l *LinkedList) PushBackList(ol *LinkedList) {
	last := ol.Tail()
	// ��ol��ͷ����ʼ, ���ν�ol��ÿ��Value���������ĩβ
	for e := ol.Head(); e != nil; e = e.Next() {
		l.PushTail(e.Value)
		if e == last {
			break
		}
	}
}
func (l *LinkedList) Len() int { return l.length }
```
