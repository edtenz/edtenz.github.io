---
layout: post
title: "docker学习"
categories: 虚拟化
description: "docker学习"
keywords: "虚拟化", "docker"
---

## 一、docker解决什么问题？

TODO


## 二、如何安装？

### 1) 在Linux下的安装

TODO

### 2) 在Mac下的安装

TODO

### 3) 验证

```sh
docker version
# 或者
docker info
```

## 三、如何使用？


### 1) 基本命令

- 镜像
Docker 把应用程序及其依赖，打包在 image 文件里面。
```sh
# 列出本机的所有 image 文件。
docker image ls

# 删除 image 文件
docker image rm [imageName]

# 在镜像中心按照名字搜索镜像
docker search [imageName]

# 从镜像中心下载镜像到本地
docker pull [imageName]
```

- 容器
image 文件生成的容器实例，本身也是一个文件，称为容器文件。
```sh
# 列出本机正在运行的容器
docker container ls

# 列出本机所有容器，包括终止运行的容器
docker container ls --all

# 删除容器文件
docker container rm [containerId]

# 运行容器中的镜像【第一次】
docker container run [imageName]

# 启动容器中的服务
docker container start [containerId]

# 停止容器中的服务
docker container stop [containerId]

# 强制停止容器中的服务
docker container kill [containerId]
```


### 2) 如何下载一个第三方镜像？

```sh
docker search nacos
docker pull nacos/nacos-server

# 运行镜像
docker run --name nacos-standalone -e MODE=standalone -p 8848:8848 nacos/nacos-server:latest
```

### 3) 如何发布一个自己的镜像？

TODO

## 四、总结

TODO



## 参考资料：
1. [Docker 入门教程]([link](http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html))

