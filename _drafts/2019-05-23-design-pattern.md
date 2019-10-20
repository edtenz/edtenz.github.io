---
layout: post
title: "设计模式在JDK中的使用"
categories: 设计模式
description: "java中的设计模式"
keywords: "设计模式", "java"
---

## 几个设计原则
- 封装变化量
- 组合优于继承
- 面向接口编程
- 追求交互对象之间的松耦合
- 开闭原则（对修改关闭，对扩展开放）
- 依赖抽象，而非具体实现
- 单一职责

## 几大设计模式
- 策略模式(Strategy)
- 观察者模式(Observer)
- 模板模式(Template)
- 复合模式(Composite)
- 命令模式(Command)
- 门面模式(Facade)
- 迭代器模式(Iterator)
- 设配器模式(Adapter)
- 状态模式(State)
  

## 策略模式 & Comparator
- 场景：
- 要解决什么问题：
- 要点：
- 策略模式定义：
- 在JDK中的应用： List#sort(Comparator)
  如果我们要对一个电影清单进行排序，排序方式可能通过名字、上映年份，也可以通过评分。
- 总结：

## 观察者模式 & Swing
- 场景：
- 要解决什么问题：
- 要点：
- 策略模式定义：
- 在JDK中的应用：JButton#performActionListener
  在一次按钮的点击，同时触发多个动作。
- 总结：

## 模板模式 & InputStream
- 场景：
- 要解决什么问题：
- 要点：
- 策略模式定义：
- 在JDK中的应用：InputStream#read
  读取数组时，read的这一子步骤为抽象方法。
- 总结：



## 参考资料：
1. [design pattern in java core libraries](https://stackoverflow.com/questions/1673841/examples-of-gof-design-patterns-in-javas-core-libraries)