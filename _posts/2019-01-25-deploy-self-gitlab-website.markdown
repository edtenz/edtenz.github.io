---
layout: post
title:  "搭建gitlab服务器"
date:   2019-01-25 14:46:05 +0000
categories: gitlab linux
---

## 一、安装gitlab

在ubuntu系统下使用apt安装：
在线安装：
```
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce=8.12.7-ce.0
```
或者使用离线安装：
```
# 下载
wget --content-disposition https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/gitlab-ce_8.12.7-ce.0_amd64.deb/download.deb
# 安装
sudo dpkg -i gitlab-ce_8.12.7-ce.0_amd64.deb
```


## 二、基本配置

- 安装后配置`/etc/gitlab/gitlab.rb`。

```
sudo vim /etc/gitlab/gitlab.rb
```

内容下列配置：
```
external_url 'http://gitlab.example.com'
# 使用系统的nginx
web_server['external_users'] = ['www-data']
nginx['enable'] = false

```

修改之后执行：

```
sudo gitlab-ctl reconfigure
```

## 三、配置反向代理
在`/etc/nginx/conf.d`目录下增加`gitlab.conf`文件：
假设本机已经启用一个8080端口的web服务。
```
sudo vim /etc/nginx/conf.d/gitlab.conf
```
内容如下：
```
upstream gitlab {
  server unix://var/opt/gitlab/gitlab-rails/sockets/gitlab.socket;
}

server {
  listen *:80;
  listen [::]:80;

  server_name gitlab.example.com;  

  server_tokens off;     # don't show the version number, a security best practice
  root /opt/gitlab/embedded/service/gitlab-rails/public;

  # Increase this if you want to upload large attachments
  # Or if you want to accept large git objects over http
  client_max_body_size 250m;

  # individual nginx logs for this gitlab vhost
  access_log  /data/appLogs/nginx/gitlab/gitlab_access.log;
  error_log   /data/appLogs/nginx/gitlab/gitlab_error.log;

  location / {
    # serve static files from defined root folder;.
    # @gitlab is a named location for the upstream fallback, see below
    try_files $uri $uri/index.html $uri.html @gitlab;
  }

  # if a file, which is not found in the root folder is requested,
  # then the proxy pass the request to the upsteam (gitlab unicorn)
  location @gitlab {
    # If you use https make sure you disable gzip compression 
    # to be safe against BREACH attack

    proxy_read_timeout 300; # Some requests take more than 30 seconds.
    proxy_connect_timeout 300; # Some requests take more than 30 seconds.
    proxy_redirect     off;

    proxy_set_header   X-Forwarded-Proto $scheme;
    proxy_set_header   Host              $http_host;
    proxy_set_header   X-Real-IP         $remote_addr;
    proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header   X-Frame-Options   SAMEORIGIN;

    proxy_pass http://gitlab;
  }

  # Enable gzip compression as per rails guide: http://guides.rubyonrails.org/asset_pipeline.html#gzip-compression
  # WARNING: If you are using relative urls do remove the block below
  # See config/application.rb under "Relative url support" for the list of
  # other files that need to be changed for relative url support
  location ~ ^/(assets)/  {
    root /opt/gitlab/embedded/service/gitlab-rails/public;
    # gzip_static on; # to serve pre-gzipped version
    expires max;
    add_header Cache-Control public;
  }

  error_page 502 /502.html;
}
```

再执行：
```
sudo nginx -t 			#nginx配置语法检查
sudo certbot --nginx		#https证书关联
sudo systemctl reload nginx	#nginx配置重新加载
```
即可。

然后通过`https://gitlab.example.com`访问，首次会让设置管理员密码。

---

## 参考资料：
1. [gitlab](https://docs.gitlab.com/omnibus/) 

