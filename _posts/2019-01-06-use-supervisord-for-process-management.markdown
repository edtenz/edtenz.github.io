---
layout: post
title:  "使用supervisord做进程管理"
date:   2019-01-06 09:46:05 +0000
categories: supervisord linux
---

## 一、基本命令
启动supervisord服务
```sh
supervisord -c /etc/supervisor/supervisord.conf
```

启动supervisorctl客户端
```sh
supervisorctl -c /etc/supervisor/supervisord.conf
```
或者
```sh
supervisorctl -u <user> -p <password>
```
直接使用命令
```sh
supervisorctl -u <user> -p <password> <opts>
```
opts包括:
> add    exit      open  reload  restart   start   tail   
avail  fg        pid   remove  shutdown  status  update 
clear  maintail  quit  reread  signal    stop    version

## 二、基本配置
新建配置目录：
```sh
sudo mkdir /etc/supervisor/conf.d
```

新建主配置文件：
```sh
/etc/supervisor/supervisord.conf
```

内容如下：

```ini
[unix_http_server]
file=/tmp/supervisor.sock 

[inet_http_server]
port=*:9001
username=loginname
password=loginpass

[supervisord]
logfile=/data/appLogs/supervisor/supervisord.log 
logfile_maxbytes=20MB 
logfile_backups=5 
loglevel=info 
pidfile=/run/supervisord.pid 
nodaemon=false 
minfds=1024 
minprocs=200 

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
; serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL for a unix socket
serverurl=http://127.0.0.1:9001
username=loginname
password=loginpass


[include]
files=init.d/*.conf
```

这里涉及到一个访问控制的问题，设置好登录名和密码（注意，这里的登录用户区别于系统里的用户）

以shadowsocks程序为例:
```sh
sudo vim /etc/supervisor/conf.d/shadowsocks.conf
```
内容如下：
```ini
[program:shadowsocks]
command=/usr/local/bin/ssserver -c /etc/shadowsocks.json --user somename -q start
process_name=%(program_name)s
directory=/tmp
autostart=true
autorestart=true
startsecs=5
exitcodes=0,2
user=somename
redirect_stderr=true
stdout_logfile=/data/appLogs/shadowsocks/ssserver.log
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=5
```
**注意**：shadowsocks不能以后台daemon方式启动，启动时不需带`-d`参数，`ssserver -c /etc/shadowsocks.json -d start`，子进程以后台方式启动，supervisord无法管理到，在supervisord上看到的状态是错误状态。

更多配置见：[supervisor](http://supervisord.org/configuration.html)


配置好启动supervisord后台服务：
```sh
sudo supervisord -c /etc/supervisor/supervisord.conf
```

通过supervisorctl连接：
```sh
supervisorctl -u loginname -p loginpass start shadowsocks
```

或者进入supervisorctl控制台：
```sh
supervisorctl
```

## 三、通过Web和使用XMLRPC控制
- 通过浏览器访问：
`http://localhost:9001/`


- 使用编程控制：
在`supervisord.conf`配置好
```
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
```

代码示例：
```py
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from xmlrpc.client import ServerProxy

server = ServerProxy('http://localhost:9001/RPC2')
stat = server.supervisor.getState()
print(stat)
```

## 四、使用systemd启动supervisord
新增配置文件：
```sh
sudo vim /lib/systemd/system/supervisord.service
```
内容如下：
```sh
[Unit]
Description=supervisord
After=syslog.target
After=network.target

[Service]
Type=forking
PIDFile=/run/supervisord.pid
ExecStart=/usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
ExecStop=/usr/local/bin/supervisorctl -c /etc/supervisor/supervisord.conf shutdown
ExecReload=/usr/local/bin/supervisorctl -c /etc/supervisor/supervisord.conf reload
KillMode=process
Restart=on-failure
RestartSec=50s
User=root
Group=root

[Install]
WantedBy=multi-user.target
```
开机自启动：
```sh
sudo systemctl enable supervisord.service
```
取消开机自启动：
```sh
sudo systemctl disable supervisord.service
```
Systemd 默认从目录`/etc/systed/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录`/lib/systemd/system/`，真正的配置文件存放在那个目录。

`systemctl enable`命令用于在上面两个目录之间，建立符号链接关系。
与之对应的，`systemctl disable`命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。

使用systemd启动supervisord：
```sh
sudo systemd start supervisord
```
查看supervisord状态：
```sh
sudo systemd status supervisord
```

## 五、更多第三方应用或类库

[第三方应用](http://supervisord.org/plugins.html)



---

## 参考资料：
1. [supervisord官方文档](http://supervisord.org/configuration.html) 
2. [supervisor FATAL Exited too quickly](https://github.com/Supervisor/supervisor/issues/578#issuecomment-74214443)
3. [阮一峰systemd配置](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
