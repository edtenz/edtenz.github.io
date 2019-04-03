---
layout: wiki
title: CAP和BASE理论
categories: [wiki, distribute]
description: CAP和BASE理论
keywords: cap, base
---

## 一、CAP理论
CAP理论为：一个分布式系统最多只能同时满足一致性（Consistency）、可用性（Availability）和分区容错性（Partition tolerance）这三项中的两项。

### 一致性（Consistency）
一致性指“all nodes see the same data at the same time”，即更新操作成功并返回客户端完成后，所有节点在同一时间的数据完全一致。

### 可用性（Availability）
可用性指“Reads and writes always succeed”，即服务一直可用，而且是正常响应时间。

### 分区容错性（Partition tolerance）
分区容错性指“the system continues to operate despite arbitrary message loss or failure of part of the system”，即分布式系统在遇到某节点或网络分区故障的时候，仍然能够对外提供满足一致性和可用性的服务。

---

## 二、 BASE理论
ASE理论是对CAP理论的延伸，核心思想是即使无法做到强一致性（Strong Consistency，CAP的一致性就是强一致性），但应用可以采用适合的方式达到最终一致性（Eventual Consitency）。

BASE是指基本可用（Basically Available）、软状态（ Soft State）、最终一致性（ Eventual Consistency）。

### 基本可用（Basically Available）
基本可用是指分布式系统在出现故障的时候，允许损失部分可用性，即保证核心可用。
电商大促时，为了应对访问量激增，部分用户可能会被引导到降级页面，服务层也可能只提供降级服务。这就是损失部分可用性的体现。

### 软状态（ Soft State）
软状态是指允许系统存在中间状态，而该中间状态不会影响系统整体可用性。分布式存储中一般一份数据至少会有三个副本，允许不同节点间副本同步的延时就是软状态的体现。mysql replication的异步复制也是一种体现。

### 最终一致性（ Eventual Consistency）
最终一致性是指系统中的所有数据副本经过一定时间后，最终能够达到一致的状态。弱一致性和强一致性相反，最终一致性是弱一致性的一种特殊情况。
