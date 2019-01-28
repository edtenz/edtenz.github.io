---
layout: post
title:  "为nginx配置HTTPS访问"
description: "为nginx配置HTTPS访问"
categories: nginx
---
Nginx 是一个高效的 HTTP 服务器，一般可用于做网站的反向代理和负载均衡。本文简单介绍了 Nginx 的基本配置和 SSL 安全通信的配置及使用。


## 一、安装Nginx

在ubuntu系统下使用apt安装：
```sh
sudo apt-get update
sudo apt-get install nginx
```

## 二、基本配置

1. 使用systemd来进行管理nginx的开机自启动和启停。

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

启动好之后就可以通过`http://localhost`s访问了。

2. 禁用默认主页

```sh
sudo vim /etc/nginx/nginx.conf
```

将`include /etc/nginx/sites-enabled/*;`改为`include /etc/nginx/sites-enabled/*.conf;`，再禁用默认：
```sh
sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.disable
```


## 三、配置反向代理
在`/etc/nginx/conf.d`目录下增加`example.conf`文件：
假设本机已经启用一个8080端口的web服务。
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
        proxy_pass http://localhost:8080/;
        proxy_set_header    Host             $host;
        proxy_set_header    X-Real-IP        $remote_addr;
        proxy_set_header    X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header    X-Client-Verify  SUCCESS;
        proxy_set_header    X-Client-DN      $ssl_client_s_dn;
        proxy_set_header    X-SSL-Subject    $ssl_client_s_dn;
        proxy_set_header    X-SSL-Issuer     $ssl_client_i_dn;
        proxy_read_timeout 1800;
        proxy_connect_timeout 1800;
    }
}
```

重新加载nginx配置：
```sh
sudo systemctl reload nginx
```

通过`http://www.example.com`即可访问服务。

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

通过`https://www.example.com`即可访问。

对于新增nginx反向代理HTTPS的支持，比如增加`/etc/nginx/conf.d/example2.conf`
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

