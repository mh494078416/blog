---
title: 项目中资源文件的获取
date: '2011-11-09'
description:
categories:
- code
- java
tags:
- code
- java
---

* 通过类加载器获取

```
InputStream inputStream1 = this.getClass().getClassLoader()
				.getResourceAsStream("ExternalResource/data.xml");
```

* spring ApplicationContext获取

```
public class SpringApplicationContextHolder implements ApplicationContextAware {
	private static ApplicationContext context;

	@Override
	public void setApplicationContext(ApplicationContext context) throws BeansException {
		SpringApplicationContextHolder.context = context;
	}

	public static Object getSpringBean(String beanName) {
		notEmpty(beanName, "bean name is required");
		return context.getBean(beanName);
	}

	public static File getResourceFile(String resource) throws IOException {
		return context.getResource(resource).getFile();
	}
}
```

需要注意的是，本地调试eclipse编译时只会把固定格式的文件（比如xml）copy到classes目录下，但txt格式的文件它是不会copy过去的。本来正常运行的代码，因为不同的文件格式却怎么也获取不到文件的输入流，在这个小坑里也折腾了好一会儿，记录下来，防止下次忘记了。
