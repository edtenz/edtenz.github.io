---
title: "使用supervisord的xmlrpc做自定义开发"
description: "使用supervisord的xmlrpc做自定义开发"
date: 2019-01-13
categories: ["supervisor"]
---

supervisor 由 supervisord, supervisorctl 和 web-UI组成，除此之外还提供了基于 XMLRPC 的接口供开发者使用，已满足个性化需求。本文主要介绍了 python, java, golang语言的 supervisor 客户端的实现范例，更多的使用按照范例扩展即可快速实现。

## 一、Python客户端

### 依赖
Python3的SDK原生支持。

### 示例
1. 连接服务器：
```java
import xmlrpc.client
def connection(host, port, username, password):
    if username == '' and password == '':
        address = 'http://{0}:{1}/RPC2'.format(host, port)
    else:
        address = 'http://{0}:{1}@{2}:{3}/RPC2'.format(
            username, password, host, port
        )
    try:
        return xmlrpc.client.ServerProxy(address)
    except Exception as e:
        print(e)
        return None
```

2. 获取supervisord状态：
```java
stat = server.supervisor.getState()
```

3. 重启supervisord：
```py
result = server.supervisor.restart()
```

4. 启动一个进程（jetty for example）：
```py
result = server.supervisor.startProcess('jetty')
```

## 二、Java客户端

使用开源的[aXMLRPC](https://github.com/gturri/aXMLRPC)客户端。aXMLRPC是一个轻量级的XML-RPC的java类库，在java和安卓上都可使用。

### maven依赖
```xml
<dependency>
    <groupId>fr.turri</groupId>
    <artifactId>aXMLRPC</artifactId>
    <version>1.12.0</version>
</dependency>
```
### 示例：
```java
XMLRPCClient client = new XMLRPCClient(new URL("http://localhost:9001/RPC2"));
client.setLoginData("someuser", "somepass");
return client.call(serviceName, params);
```

## 三、Golang客户端
示例底层依赖 [gosupervisor](https://github.com/foolin/gosupervisor)

### 安装依赖

```sh
go get github.com/foolin/gosupervisor
```

### 示例：

StartProcess示例：

```go
type SupervisorClient struct {
	url       string
	client    xmlrpc.Client
	connected bool
}

func (s *SupervisorClient) Connect() (bool, error) {
	cli, err := xmlrpc.NewClient(s.url, nil)
	if err != nil {
		s.connected = false
		return false, err
	} else {
		s.client = *cli
		s.connected = true
		return true, nil
	}
}

func BuildURL(host string, port int, username, passwd string) string {
	if len(username) == 0 || len(passwd) == 0 {
		return fmt.Sprintf("http://%s:%d/RPC2",
			host, port)
	} else {
		return fmt.Sprintf("http://%s:%s@%s:%d/RPC2", username, passwd, host, port)
	}
}

func (s *SupervisorClient) StartProcess(name string, wait bool) (success bool, err error) {
	params := []interface{}{name, wait}
	err = s.client.Call("supervisor.startProcess", params, &success)
	return
}

```

---

## 参考资料：
1. [supervisord官方文档](http://supervisord.org/api.html) 
2. [supervisord建立连接时认证](https://github.com/gamegos/cesi/blob/master/cesi/core/xmlrpc.py)
3. [java客户端AXMLRPC](https://github.com/gturri/aXMLRPC)
4. [golang客户端gosupervisor](https://github.com/foolin/gosupervisor)

