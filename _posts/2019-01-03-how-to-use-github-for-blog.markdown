---
layout: post
title:  "使用github搭建自己的博客"
date:   2019-01-03 11:08:00 +0000
categories: github jekyll
---
使用github搭建自己的博客系统，可以简单归为3个步骤：

## 安装Jekyll 
Jekyll是一个静态博客系统，不需要安装数据库，文章可以使用markdown编辑，最终以静态页面展现出来。

Jekyll的安装详情见官网[Jekyll docs][jekyll-docs]，现在以为Ubuntu系统为例：

### Ubuntu系统
1. 安装ruby依赖
```shell
sudo apt-get install ruby-full build-essential zlib1g-dev
```
2. 设置环境变量
```shell
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
3. gem安装Jekyll
```shell
gem install jekyll bundler
```

### MacOS和Windows系统
MacOS和Windows环境下的安装[Jekyll install][jekyll-install]

## 创建博客工作区

创建工作目录：
```
mkdir blogs & cd blogs
jekyll new myblog
```
会产生一个Jekyll项目的基本框架，包括一些子目录和文件，`_posts`用于存放文章,`_sites`是生成的静态HTML页面。

在本地运行：
```shell
cd myblog
bundle exec jekyll serve
```
会侦听4000端口，通过`http://localhsot:4000/`可以访问。

## 托管在github上
为了使用github进行博客展示，需要先再github上创建一个repository
命名示例如下：`EdgarTeng.github.io`


## 在个人云主机上（待补充）



[jekyll-docs]: https://jekyllrb.com/docs/
[jekyll-install]: https://jekyllrb.com/docs/installation/

