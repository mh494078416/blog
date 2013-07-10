---
title: idea intellij go "can’t find import" 解决方法
date: '2013-07-04'
description:
categories:
- Go
tags:
- intellij
- Go
- ide
---


尝试重多golang的ide，最后发现intellij目前做的完成度最高

eclipse go 不能进行包、类、方法等的跳转，这点是无法忍受的，所以果断换成intellij

但是发现在intellij里面不能import `$GOPATH`里src下的包，网上搜索了很长时间，
在这里找到解决方法：<https://github.com/mtoader/google-go-lang-idea-plugin/issues/224>

>
	Looking through the source, it seems that the plugin doesn't use the $GOPATH (to be fair, I think earlier Go docs didn't make the distinction between using $GOPATH and $GOROOT quite as clear as they do now).
	In setting up the plugin you have to 
	1.) create symlinks for all of the imported package directories in your $GOPATH:
		a. $GOROOT/src/pkg/ -> $GOPATH/src
		ex. from within $GOROOT/src/pkg, ln -s $GOPATH/src/github.com
		b. $GOROOT/pkg/target/ -> $GOPATH/pkg/target/
		ex. from within $GOROOT/pkg/darwin_amd64, ln -s $GOPATH/pkg/darwin_amd64/code.google.com
	2.) you MUST set up a source directory when creating the project (however, it can be an empty string, which will then cause the wizard to prompt you that it will set the project root as the source directory)

附上一片比较完整搭建go环境的博文：
<http://icfly.cn/archives/2013/05/golang-ide.html>
