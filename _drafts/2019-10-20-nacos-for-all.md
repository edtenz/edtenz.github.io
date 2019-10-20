---
layout: post
title: "nacos学习"
categories: 设计模式
description: "nacos学习"
keywords: "注册中心", "java"
---

## nacos解决什么问题？

## nacos的架构是怎样的？



nacos一致性协议

![nacos-consistency-protocol](../images/posts/nacos/nacos-consistency-protocol.png)




## nacos是如何xxx问题的？


## 如何使用？

- docker
```sh
docker search nacos
docker pull nacos/nacos-server
# 单机方式启动
docker run --name nacos-standalone -e MODE=standalone -p 8848:8848 nacos/nacos-server:latest
```
- 测试
```
http://192.168.99.100:8848/nacos
```

## nacos的不足是什么？


## 总结



## 参考资料：
1. [title](link)
