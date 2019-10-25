---
layout: post
title: "docker学习"
categories: 虚拟化
description: "docker学习"
keywords: "虚拟化", "docker"
---

## 一、docker解决什么问题？

1) 环境配置的难题；
2) 快速扩缩容；
3) 虚拟机资源占用过多；


Docker 属于 Linux 容器的一种封装，提供简单易用的容器使用接口。它是目前最流行的 Linux 容器解决方案。
Docker 将应用程序和环境依赖打包成一个文件，运行这个文件，生成一个虚拟容器文件，进程在容器运行就像在真是的物理机上运行一样。且能通过docker实现应用及其环境的复制、分发，实现共享。

## 二、如何安装？

### 1) 在Linux下的安装

- Unbuntu
安装参考：[Get Docker Engine - Community for Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-engine---community-1)

基本启停：
```sh
sudo systemctl start docker
sudo systemctl stop docker
sudo systemctl status docker
```

1) 解决普通用户无法运行 docker 的问题：
> Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.40/images/search?limit=25&term=nginx: dial unix /var/run/docker.sock: connect: permission denied

解决方案：
```sh
# 创建 docker 组
sudo groupadd docker
# 将用户加入到 docker 组
sudo usermod -aG docker $USER
```
注销用户重新登录即可！

2) 配置国内镜像:
```sh
vim /etc/docker/daemon.json
```
内容如下：
```js
{
  "registry-mirrors": ["https://yourcode.mirror.aliyuncs.com"]
}
```
重启：
```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 2) 在Mac & Windows 下的安装

安装参考：
[Mac](https://docs.docker.com/docker-for-mac/install/)
[Windows](https://docs.docker.com/docker-for-windows/install/)

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

- 其他有用命令

```sh
# 查看 docker 容器的输出
docker container logs [containerID]

# 命令用于进入一个正在运行的 docker 容器，一旦进入了容器，就可以在容器的 Shell 执行命令了
docker container exec -it [containerID] /bin/bash

# 从正在运行的 Docker 容器里面，将文件拷贝到本机
docker container cp [containID]:[/path/to/file.ext] [/local/path]

# 拷贝本地文件到从正在运行的 Docker 容器里面，并覆盖文件
docker container cp [/local/path/file.ext] [containID]:[/path/to/file.ext]

# 查看docker中的进程
docker ps -a

# 用本地文件替换 docker 容器中的对应目录
# -v $PWD/www:/www把主机当前目录下的www目录绑定到了docker中www目录。
# 由于docker容器需要对nginx.conf的访问权限，因此，绑定nginx.conf文件时，后面添加--privileged=true命令。
docker run -p 80:80 --name mynginx -v $PWD/www:/www -v $PWD/conf/nginx.conf:/etc/nginx/nginx.conf --privileged=true -v $PWD/logs:/www/logs -v $PWD/html:/etc/nginx/html  -d nginx
```




### 2) 如何下载一个第三方镜像？

```sh
docker search nacos
docker pull nacos/nacos-server

# 运行镜像
docker run --name nacos-standalone -e MODE=standalone -p 8848:8848 nacos/nacos-server:latest
```

### 3) 如何发布一个自己的镜像？
1. 编写dockerFile

```dockerfile
FROM java:8
COPY dist/ /app/
WORKDIR /app
EXPOSE 8082
ENTRYPOINT ["bin/run.sh"]
```

   


2. 构建镜像

```sh
docker image build -t five-chess:v1 .
```
上面代码中，-t参数用来指定 image 文件的名字，后面还可以用冒号指定标签。如果不指定，默认的标签就是latest。最后的那个点表示 Dockerfile 文件所在的路径，上例是当前路径，所以是一个点。


3. 运行
```sh
docker run --name chess -p 8082:8082 five-chess:v1
```

## 四、总结

本文对 Docker 的一些基本概念、解决什么问题做了介绍，并整理了在安装和使用 Docker 过程中常碰到的问题和，经常用到的命令。最后通过一个小例子，演示了如何生成自己的 Docker 镜像文件。



## 参考资料：
1. [Docker 入门教程]([link](http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html))
2. [Get Docker Engine - Community for Ubuntu]([link](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-engine---community-1))

