---
title: "使用 Hugo + PaperMod + GitHub Actions 搭建静态博客"
description: "介绍如何使用 Hugo、PaperMod 主题和 GitHub Actions 自动化部署来搭建一个现代化的静态博客网站"
date: 2024-12-19
categories: ["环境搭建", "hugo"]
tags: ["Hugo", "PaperMod", "GitHub Actions", "静态博客", "GitHub Pages"]
---

## 为什么选择这个方案？

在众多静态博客生成器中，**Hugo + PaperMod + GitHub Actions** 的组合提供了以下优势：

### 1. **极致的性能**
- Hugo 使用 Go 语言编写，构建速度极快，即使是包含数千篇文章的大型网站，也能在几秒内完成构建
- 生成的静态 HTML 文件加载速度快，用户体验优秀

### 2. **现代化的主题**
- PaperMod 是一个功能丰富、设计精美的 Hugo 主题
- 支持暗色模式、代码高亮、搜索功能、阅读进度等现代化特性
- 响应式设计，完美适配各种设备

### 3. **完全自动化**
- GitHub Actions 实现 CI/CD，推送代码即自动部署
- 无需手动构建和上传，专注于内容创作
- GitHub Pages 提供免费的 HTTPS 和 CDN 加速

### 4. **版本控制与协作**
- 所有内容通过 Git 管理，可以追踪历史、回滚版本
- 支持多人协作，可以 Review 文章后再发布

## 解决了什么问题？

### 传统博客平台的痛点
- **平台限制**：受限于平台的功能和审查政策
- **数据所有权**：内容存储在第三方平台，迁移困难
- **定制化差**：难以自定义样式和功能
- **成本问题**：高级功能需要付费

### 这个方案的优势
- ✅ **完全自主**：拥有所有数据和代码
- ✅ **免费托管**：GitHub Pages 完全免费
- ✅ **高度定制**：可以修改主题、添加功能
- ✅ **Markdown 写作**：专注于内容，无需关心排版
- ✅ **自动化部署**：写文章、推代码、自动发布

## 如何使用

### 第一步：安装 Hugo

#### macOS
```bash
brew install hugo
```

#### Linux
```bash
sudo apt-get install hugo
# 或使用 snap
sudo snap install hugo
```

#### Windows
下载预编译二进制文件：https://github.com/gohugoio/hugo/releases

验证安装：
```bash
hugo version
```

### 第二步：创建 Hugo 站点

```bash
# 创建新站点
hugo new site my-blog
cd my-blog

# 添加 PaperMod 主题（作为 Git 子模块）
git init
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
```

### 第三步：配置 Hugo

创建或编辑 `config.toml`：

```toml
baseURL = 'https://yourusername.github.io/'
languageCode = 'zh-cn'
title = '我的博客'
theme = 'PaperMod'

[params]
  env = 'production'
  description = '我的个人博客'
  author = 'Your Name'
  ShowReadingTime = true
  ShowPostNavLinks = true
  ShowCodeCopyButtons = true
  UseHugoToc = true

[menu]
  [[menu.main]]
    identifier = "home"
    name = "首页"
    url = "/"
    weight = 10
  [[menu.main]]
    identifier = "posts"
    name = "文章"
    url = "/posts/"
    weight = 20
```

### 第四步：创建第一篇文章

```bash
hugo new posts/my-first-post.md
```

编辑文章，添加内容：

```markdown
---
title: "我的第一篇文章"
date: 2024-12-19
categories: ["技术"]
---

这是文章内容，使用 Markdown 格式编写。
```

### 第五步：本地预览

```bash
hugo server -D
```

访问 http://localhost:1313 查看效果。

### 第六步：配置 GitHub Actions

在项目根目录创建 `.github/workflows/hugo.yml`：

```yaml
name: Deploy Hugo site to Pages

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
          fetch-depth: 0
      
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
          extended: true
      
      - name: Build
        run: hugo --minify
      
      - name: Setup Pages
        uses: actions/configure-pages@v4
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 第七步：推送到 GitHub

```bash
# 创建 GitHub 仓库（命名为 yourusername.github.io）
# 然后推送代码

git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/yourusername.github.io.git
git push -u origin main
```

### 第八步：启用 GitHub Pages

1. 进入仓库的 **Settings** → **Pages**
2. 在 **Source** 中选择 **GitHub Actions**
3. 等待 Actions 完成构建和部署
4. 访问 `https://yourusername.github.io` 查看你的博客

## 后续使用

### 发布新文章
1. 创建新文章：`hugo new posts/article-name.md`
2. 编辑文章内容
3. 提交并推送：
   ```bash
   git add .
   git commit -m "Add new post"
   git push
   ```
4. GitHub Actions 会自动构建并部署

### 本地开发
```bash
# 启动开发服务器（支持热重载）
hugo server -D

# 构建静态文件
hugo --minify
```

## 总结

使用 **Hugo + PaperMod + GitHub Actions** 搭建博客，你只需要：
- 专注于内容创作（Markdown）
- 推送代码到 GitHub
- 自动部署到 GitHub Pages

整个过程简单高效，完全免费，且拥有完全的控制权。开始你的博客之旅吧！

