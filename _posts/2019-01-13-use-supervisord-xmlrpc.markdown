---
layout: post
title:  "使用supervisord的xmlrpc做自定义开发"
date:   2019-01-13 18:46:05 +0000
categories: supervisord linux
---

## 一、建立连接
1. 连接服务器：
```
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

## 二、 supervisord管理

1. 查看方法列表：
```py
server = connection('localhost', 9001, 'someuser', 'somepass')
methods = server.system.listMethods()
print(methods)
```
支持的方法:
supervisor.addProcessGroup
supervisor.clearAllProcessLogs
supervisor.clearLog
supervisor.clearProcessLog
supervisor.clearProcessLogs
supervisor.getAPIVersion
supervisor.getAllConfigInfo
supervisor.getAllProcessInfo
supervisor.getIdentification
supervisor.getPID
supervisor.getProcessInfo
supervisor.getState
supervisor.getSupervisorVersion
supervisor.getVersion
supervisor.readLog
supervisor.readMainLog
supervisor.readProcessLog
supervisor.readProcessStderrLog
supervisor.readProcessStdoutLog
supervisor.reloadConfig
supervisor.removeProcessGroup
supervisor.restart
supervisor.sendProcessStdin
supervisor.sendRemoteCommEvent
supervisor.shutdown
supervisor.signalAllProcesses
supervisor.signalProcess
supervisor.signalProcessGroup
supervisor.startAllProcesses
supervisor.startProcess
supervisor.startProcessGroup
supervisor.stopAllProcesses
supervisor.stopProcess
supervisor.stopProcessGroup
supervisor.tailProcessLog
supervisor.tailProcessStderrLog
supervisor.tailProcessStdoutLog
system.listMethods
system.methodHelp
system.methodSignature
system.multicall




2. 获取supervisord状态：
```py
stat = server.supervisor.getState()
```

3. 重启supervisord：
```py
result = server.supervisor.restart()
```

## 三、进程管理

1. list配置信息：
```py
configs = server.supervisor.getAllConfigInfo()
```


2. list进程信息：
```py
processes = server.supervisor.getAllProcessInfo()
```

3. 启动一个进程（jetty for example）：
```py
result = server.supervisor.startProcess('jetty')
```

4. 停止一个进程：
```py
result = server.supervisor.stopProcess('jetty')
```


---

## 参考资料：
1. [supervisord官方文档](http://supervisord.org/api.html) 
2. [supervisord建立连接时认证](https://github.com/gamegos/cesi/blob/master/cesi/core/xmlrpc.py)

