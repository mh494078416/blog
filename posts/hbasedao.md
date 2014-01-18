---
title: hbase orm中间层hbasedao
date: '2014-01-03'
description: hbase orm
categories:
- hbase
- java
tags:
- hbase
- java
---


背景
---
hbase是分布式的kv(key value)存储系统，hbase提供的针对底层数据的操作也是基于kv维度的，使用起来更像是Map的操作方式。但是上层业务应用一般是采用的面向对象的设计，这就导致了使用hbase的底层api必须要写很多的代码来做KV原始数据到上层业务对象的转化。

使用关系型数据库如MySQL，也会遇到关系型数据跟对象之间的适配问题，所以出现了很多成熟的做对象关系映射的产品，像`hibernate`和`mybatis`。

hbase当然也需要一个类似的东西，来做对象到kv数据的适配，这样上层应用可以继续专注于上层 面向对象的方式的开发，而不用直接操作kv数据，提高工作效率。

hbase使用场景
---
hbase要解决的问题是海量数据的分布式存储，传统数据库如mysql解决这个问题也是有办法的，可以通过分库分表的方式做到。
所以，hbase和mysql的竞争点是在需要mysql分库分表的情况。下面以一个很常见的场景举例，来看之前数据存储使用mysql的场景，迁移hbase上的过程。

>问题描述：用户的基本信息（包括：用户头像，上次登录时间），好友关系（正向 我关注的人，反向关注我的人）

#### mysql的方式：

* 用户信息表

| 列名					| 说明				|
| ----------------- |:-------------:	|
| id     				| 用户id		 	|
| head_image  		| 头像				|
| last_visit_time	| 上次登录时间		|

* 用户关注表

| 列名					| 说明				|
| ----------------- |:-------------:	|
| userId     			| 用户id		 	|
| follow_user  		| 关注的人			|

* 用户粉丝表

| 列名					| 说明				|
| ----------------- |:-------------:	|
| userId     			| 用户id		 	|
| be_followed_user  | 关注我的人		|

>之所以用户关系两张表来保存是因为，用户关系数据量比较大的情况下，采用分库分表存储的方案，又要提供正向、反向的查询，所以需要分别以关注者和被关注者为路由字段存储两份。

#### hbase的方式：

| rowKey	| 列簇							|列	|
|-------- |-------------------------	|---------|
| userId  | info_cf（单version）		| head_image|
| 			| 								|last_visit_time|
| 			| relation_cf	(多个version)	|follow_user|
| 			| 								|be_followed_user|

存入hbase的数据的逻辑结构会是：
![hbase_data.png](http://www.codeforfun.info/assets/media/hbase_data.png)

> 通过上面mysql表到hbase表的迁移过程，可以清楚地看到：mysql中 和userId一对一的用户基本信息迁移到hbase可以用无version特性的列簇保存；一对多的关注关系迁移到hbase，可以利用hbase多version的列簇保存。下面介绍的hbasedao中间层就会主要解决mysql迁移到hbase的适配，包括单version（一对一）和多version（一对多）的情形。

> **NOTE：**
hbase多version的列簇，不同column之间没有任何对应关系，所以不要尝试在不同的column之间找行的对应关系。


hbasedao介绍
---
hbasedao是一个简单地解决kv数据到业务对象适配的中间层，类似关系型数据库orm中间层`mybatis`。

#### 针对于hbase存储结构抽象出来的类结构：
![habasedao_realtion.png](http://www.codeforfun.info/assets/media/hbasedao_relation.png)
#### 使用
封装业务对象成DO类，一个rowKey对应一个DO类的对象，通过指定DO类里的column，中间层可以做到针对于指定column的查询。使用hbasedao之后，查询的方式如下：

```
public UserHBaseDO get(String rowKey) throws HBaseDAOException {
	HBaseDO hBaseDO = new HBaseDO();
	hBaseDO.setTableName(UserHBaseDO.TABLE_NAME);
	hBaseDO.setRowKey(rowKey);
	hBaseDO.addColumnFamily(UserHBaseDO.CF_NAME_info_cf)
		.putColumn(UserHBaseDO.CL_NAME_head_image)
		.putColumn(UserHBaseDO.CL_NAME_last_visit_time);
	hBaseDO.addColumnFamily(UserHBaseDO.CF_NAME_relation_cf, 10)
		.putColumn(UserHBaseDO.CL_NAME_follow_user)
		.putColumn(UserHBaseDO.CL_NAME_be_followed_user);
	super.getHbaseDao().get(hBaseDO);
	UserHBaseDO userHBaseDO = null;
	try {
		userHBaseDO = new UserHBaseDO(hBaseDO);
	} catch (UnsupportedEncodingException e) {
		new HBaseDAOException(e);
	}
	return userHBaseDO;
}
```
#### 支持的API

1. 以对象的方式插入数据
2. 批量插入数据
3. 传入rowKey，查询对象。可支持针对不同的列簇指定查询的version数量，支持指定列簇中数据的时间范围
4. 传入多个rowKey，查询对象的列表
5. 删除指定的rowKey的一行记录
6. 指定开始扫描的rowKey，开始按行扫描数据，可以限制扫描的结果集大小

```
public interface HBaseDAO {
	public void put(HBaseDO hBaseDO) throws HBaseDAOException;
	public void putList(List<HBaseDO> hBaseDOList, String tableName) 
		throws HBaseDAOException;
	public void get(HBaseDO hBaseDO) throws HBaseDAOException;
	public void getList(List<HBaseDO> hBaseDOList, String tableName) 
		throws HBaseDAOException;
	public void delete(HBaseDO hBaseDO) throws HBaseDAOException;
	public List<HBaseDO> scan(String tableName, String startRow, String endRow, 
		int maxVersion, int maxResultSize, Map<String, List<String>> columnFamilyMap) 
		throws HBaseDAOException;
}
```

使用举例（step by step）
---

代码工程结构，sample包里提供了详细的使用举例。可以看到，使用时只需要定义hbase表对应的DO类，在此类中编写对象和hbase里数据的对应关系，在DAO层以上就可以提供和mybatis类似的接口访问形式。

```
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com
│   │   │       └── taobao
│   │   │           └── hbasedao
│   │   │               ├── ColumnFamilyInfo.java
│   │   │               ├── HBaseCell.java
│   │   │               ├── HBaseClientDaoSupport.java
│   │   │               ├── HBaseColumnFamily.java
│   │   │               ├── HBaseConsole.java
│   │   │               ├── HBaseDAO.java
│   │   │               ├── HBaseDAOException.java
│   │   │               ├── HBaseDAOFactory.java
│   │   │               ├── HBaseDAOImpl.java
│   │   │               ├── HBaseDO.java
│   │   │               ├── HBaseVO.java
│   │   │               ├── MapAble.java
│   │   │               └── sample
│   │   │                   ├── dao
│   │   │                   │   └── UserHBaseDAO.java
│   │   │                   ├── dataobject
│   │   │                   │   └── UserHBaseDO.java
│   │   │                   └── vo
│   │   │                       └── FollowerVO.java
│   │   └── resources
│   └── test
│       ├── java
│       │   └── com
│       │       └── taobao
│       │           └── hbasedao
│       │               └── sample
│       │                   └── test
│       │                       └── UserHBaseDAOTest.java
│       └── resources
│           └── hbase-dao.xml
```

#### 步骤

1. 引入依赖

	```
<dependency>
  <groupId>com.taobao.hbasedao</groupId>
  <artifactId>hbasedao</artifactId>
  <version>1.0.0-SNAPSHOT</version>
</dependency>
```

2. 定义hbae表对应的DO类，相当于使用mybatis时，定义的sqlmap，需要给出hbase表的schema信息，如：列簇名、列名、列簇的最大version，列簇和列的绑定关系等。

	```
public class UserHBaseDO implements MapAble<UserHBaseDO> {
	public static final String TABLE_NAME = "hbasedao_user";
	public static final String CF_NAME_info_cf = "info_cf";
	public static final int MAX_SIZE_CF_NAME_info_cf = 1;
	public static final String CF_NAME_relation_cf = "relation_cf";
	public static final int MAX_SIZE_CF_NAME_relation_cf = 1000;
	public static final String CL_NAME_head_image = "head_image";
	public static final String CL_NAME_last_visit_time = "last_visit_time";
	public static final String CL_NAME_follow_user = "follow_user";
	public static final String CL_NAME_be_followed_user = "be_followed_user";
	private static Map<String, List<String>> columnFamilyMap;
	static {
		columnFamilyMap = new HashMap<String, List<String>>();
		columnFamilyMap.put(CF_NAME_info_cf,
				Arrays.asList(new String[] { CL_NAME_head_image, CL_NAME_last_visit_time }));
		columnFamilyMap.put(CF_NAME_relation_cf,
				Arrays.asList(new String[] { CL_NAME_follow_user, CL_NAME_be_followed_user }));
	}
	private String rowKey;
	private String headImage;
	private long lastVisitTime;
	private final List<FollowerVO> followVOList = new ArrayList<FollowerVO>();
	private final List<FollowerVO> beFollowedVOList = new ArrayList<FollowerVO>();
```

3. 实现MapAble接口，MapAble接口包括两个方法，一个是插入数据时将用户定义的UserHBaseDO转化为框架使用的HBaseDO，一个是查询时将HBaseDO里包含的数据转为为用户定义UserHBaseDO。

	```
@Override
public HBaseDO converDOToHBaseDO() {
	HBaseDO hbaseDO = new HBaseDO();
	hbaseDO.setRowKey(this.rowKey);
	hbaseDO.setTableName(UserHBaseDO.TABLE_NAME);
	for (Map.Entry<String, List<String>> columnFamilyEntry : 
		columnFamilyMap.entrySet()) {
		String columnFamilyName = columnFamilyEntry.getKey();
		List<String> columnNameList = columnFamilyEntry.getValue();
		HBaseColumnFamily columnFamily = new HBaseColumnFamily();
		for (String columnName : columnNameList) {
			if (CF_NAME_info_cf.equals(columnFamilyName) && 
				CL_NAME_head_image.equals(columnName)) {
				if (this.headImage != null) {
					List<HBaseCell> cellDOList = new ArrayList<HBaseCell>();
					HBaseCell cellDO = new HBaseCell();
					cellDO.setValue(this.headImage);
					cellDOList.add(cellDO);
					columnFamily.putColumn(columnName, cellDOList);
				}
			}
			...
		}
		hbaseDO.getColumnFamilyMap().put(columnFamilyName, columnFamily);
	}
	return hbaseDO;
}
@Override
public UserHBaseDO convertHBaseDOToDO(HBaseDO hBaseDO) throws UnsupportedEncodingException {
	this.rowKey = hBaseDO.getRowKey();
	List<KeyValue> results = hBaseDO.getResults();
	for (Map.Entry<String, List<String>> columnFamilyEntry : 
		columnFamilyMap.entrySet()) {
		String columnFamilyName = columnFamilyEntry.getKey();
		List<String> columnNameList = columnFamilyEntry.getValue();
		for (String columnName : columnNameList) {
			if (CF_NAME_info_cf.equals(columnFamilyName) && 
				CL_NAME_head_image.equals(columnName)) {
				for (KeyValue kv : results) {
					if (columnFamilyName.equals(new String(kv.getFamily()))
							&& columnName.equals(new String(kv.getQualifier()))) {
						this.headImage = new String(kv.getValue(), "UTF-8");
					}
				}
			}
			...
		}
	}
	return this;
}
```

4. 然后就是定义DAO类，主要的逻辑已经在UserHBaseDO写了，这里的实现可以足够简单，查询的代码在hbasedao介绍里已经给出，插入数据的代码如下：

	```
public void insert(UserHBaseDO userHBaseDO) throws HBaseDAOException {
	super.getHbaseDao().put(userHBaseDO.converDOToHBaseDO());
}
```

5. 编写测试用例

	```
@Test
public void test_insert() throws HBaseDAOException {
	ApplicationContext context = new ClassPathXmlApplicationContext("hbase-dao.xml");
	UserHBaseDAO userHBaseDAO = context.getBean("userHBaseDAO", UserHBaseDAO.class);
	UserHBaseDO userHBaseDO = new UserHBaseDO();
	userHBaseDO.setRowKey("2222");
	userHBaseDO.setHeadImage("icon1.jpg");
	userHBaseDO.setLastVisitTime(4820023);
	int i = 0;
	FollowerVO followerVO1 = new FollowerVO("444_errik");
	followerVO1.setTimeStamp(System.currentTimeMillis() + i++);
	FollowerVO followerVO2 = new FollowerVO("555_wiie");
	followerVO2.setTimeStamp(System.currentTimeMillis() + i++);
	FollowerVO followerVO3 = new FollowerVO("666_gate");
	followerVO3.setTimeStamp(System.currentTimeMillis() + i++);
	userHBaseDO.getFollowVOList().add(followerVO1);
	userHBaseDO.getFollowVOList().add(followerVO2);
	userHBaseDO.getFollowVOList().add(followerVO3);
	FollowerVO followerVO4 = new FollowerVO("999_hena");
	userHBaseDO.getBeFollowedVOList().add(followerVO4);
	userHBaseDAO.insert(userHBaseDO);
}
@Test
public void test_get() throws HBaseDAOException {
	ApplicationContext context = new ClassPathXmlApplicationContext("hbase-dao.xml");
	UserHBaseDAO userHBaseDAO = context.getBean("userHBaseDAO", UserHBaseDAO.class);
	UserHBaseDO userHBaseDO = userHBaseDAO.get("2222");
	System.out.println(userHBaseDO);
}
```

> 完整地代码示例请参考`com.taobao.hbasedao.sample`
代码工程在：[hbasedao](https://github.com/mh494078416/hbasedao)


