---
layout: post
title:  "为nginx配置HTTPS访问"
description: "为nginx配置HTTPS访问"
categories: nginx
---

Nginx 是一个高效的 HTTP 服务器，一般可用于做网站的反向代理和负载均衡。本文简单介绍了 Nginx 的基本配置和 SSL 安全通信的配置及使用。


## 一、安装 Nginx

在ubuntu系统下使用apt安装：

```sh
sudo apt-get update
sudo apt-get install nginx
```

## 二、基本配置

1. 使用 systemd 来进行管理 nginx 的开机自启动和启停。

查看`/lib/systemd/system/nginx.service`是否存在，不存在则添加该文件

```sh
sudo vim /lib/systemd/system/nginx.service
```

内容如下：

```ini
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
```

添加之后执行：

```sh
sudo systemctl enable nginx	#开机自启动
sudo systemctl start nginx	#启动
sudo systemctl stop nginx	#停止
sudo systemctl reload nginx	#重新加载
```

启动好之后就可以通过 `http://localhost` 访问了。

2. 禁用默认主页

```sh
sudo vim /etc/nginx/nginx.conf
```

将 `include /etc/nginx/sites-enabled/*;` 改为 `include /etc/nginx/sites-enabled/*.conf;`  再禁用默认：

```sh
sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.disable
```


## 三、配置反向代理

1) HTTP(S) 反向代理配置

在 `/etc/nginx/conf.d` 目录下增加 `example.conf` 文件：

考虑一种常见使用场景：启用一个 80 端口的 web 服务。静态文件从 `/www/front` 加载，动态 API 转发至监听 `8090` 端口的 web 服务。

```sh
sudo vim /etc/nginx/conf.d/example.conf
```

内容如下：

```sh
server {
    listen 80;
    listen [::]:80;
    server_name www.example.com;

    location / {
        root   /usr/local/var/www/front;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }

    location ^~ /api/ {
        proxy_pass http://localhost:8090/api/;
    }

    location ^~ /admin/ {
        proxy_pass http://localhost:8090/admin/;

    }

}

```

重新加载 nginx 配置：

```sh
sudo systemctl reload nginx
```

通过 `http://www.example.com` 即可访问服务。

2) TCP 反向代理配置

比如配置本地 `8080` 端口到 `backend1.example.com:12345` 的转发，在 `nginx.conf` 顶层标签增加：

```conf
stream {
    include /etc/nginx/stream.d/*.conf;
}
```

在 `/etc/nginx/stream.d/` 目录下增加 `example.8080.conf` 文件：

```conf
upstream example.stream.node {
    server backend1.example.com:12345;
}

server {
    listen 8080;
    proxy_pass example.stream.node;
}
```


## 四、HTTPS支持

安装Certbot

```sh
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
sudo certbot --nginx
```

配置防火墙：

```sh
sudo apt install ufw
sudo systemctl start ufw && sudo systemctl enable ufw
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

通过 `https://www.example.com` 即可访问。

对于新增 nginx 反向代理 HTTPS 的支持，比如增加 `/etc/nginx/conf.d/example2.conf`

再执行：

```sh
sudo nginx -t 			#nginx配置语法检查
sudo certbot --nginx		#https证书关联
sudo systemctl reload nginx	#nginx配置重新加载
```

即可。



---

## 参考资料：

1. [Use NGINX as a Reverse Proxy](https://www.linode.com/docs/web-servers/nginx/use-nginx-reverse-proxy/) 

