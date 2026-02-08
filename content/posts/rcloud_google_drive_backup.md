---
title: "使用 rclone + Google Drive 实现自动与手动备份实践"
date: 2026-02-08T16:16:24+08:00
summary: "本文记录如何在 Ubuntu 服务器上，通过 **rclone + systemd timer** 实现自动每日定时备份、增量同步、排除隐藏文件、手动立即触发备份等功能，适用于个人服务器或开发环境的长期数据备份。"
---


本文记录如何在 Ubuntu 服务器上，通过 **rclone + systemd timer** 实现：

- 自动每日定时备份
- 增量同步（只上传新增/变化文件）
- 排除隐藏文件（`.` 开头）
- 手动立即触发备份
- 提供快捷命令进行单次备份

适用于个人服务器或开发环境的长期数据备份。

> 文中涉及的用户名统一使用 `yourname` 作为示例，请根据实际环境替换。

---

## 一、准备工作

### 1. 安装 rclone
```bash
sudo apt update
sudo apt install rclone
````

### 2. 配置 Google Drive

```bash
rclone config
```

创建 remote，例如：

```
name: gdrive
type: drive
```

完成 OAuth 授权后，测试：

```bash
rclone lsd gdrive:
```

若能列出目录，说明连接成功。

---

## 二、编写定时增量备份脚本

需求：

* 同步目录：`/home/yourname/apps`
* 目标：`gdrive:backup/apps`
* 增量同步（copy）
* 排除隐藏文件

创建脚本：

```bash
sudo nano /usr/local/bin/rclone-gdrive-apps-copy.sh
```

脚本内容：

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC="/home/yourname/apps"
DST="gdrive:backup/apps"

LOG_DIR="/home/yourname/.log/rclone"
LOCK_FILE="/home/yourname/.cache/rclone-gdrive-apps.lock"

mkdir -p "$LOG_DIR"

TS="$(date +%F_%H-%M-%S)"
LOG_FILE="$LOG_DIR/gdrive_apps_copy_$TS.log"

exec flock -n "$LOCK_FILE" rclone copy "$SRC" "$DST" \
  --exclude "/.*" \
  --exclude "**/.*" \
  --create-empty-src-dirs \
  --stats=30s \
  --transfers=4 \
  --checkers=8 \
  --retries=5 \
  --retries-sleep=10s \
  --drive-chunk-size=64M \
  --log-level=INFO \
  --log-file "$LOG_FILE"
```

赋权：

```bash
sudo chmod +x /usr/local/bin/rclone-gdrive-apps-copy.sh
```

---

## 三、创建 systemd 定时任务

### 1. 创建 service

```bash
sudo nano /etc/systemd/system/rclone-gdrive-apps-copy.service
```

```ini
[Unit]
Description=Rclone incremental backup
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
User=yourname
Environment=HOME=/home/yourname
Environment=RCLONE_CONFIG=/home/yourname/.config/rclone/rclone.conf
ExecStart=/usr/local/bin/rclone-gdrive-apps-copy.sh
```

---

### 2. 创建 timer（每日执行）

```bash
sudo nano /etc/systemd/system/rclone-gdrive-apps-copy.timer
```

```ini
[Unit]
Description=Daily Rclone backup

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

启用：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now rclone-gdrive-apps-copy.timer
```

查看：

```bash
systemctl list-timers
```

---

## 四、手动立即触发定时备份

无需等待定时任务，可直接执行：

```bash
sudo systemctl start rclone-gdrive-apps-copy.service
```

查看结果：

```bash
systemctl status rclone-gdrive-apps-copy.service
```

> 实用小技巧：为了方便每次手动触发备份，可以在 `~/.bashrc` 中添加一个别名：

```bash
echo "alias backup-now='sudo systemctl start rclone-gdrive-apps-copy.service'" >> ~/.bashrc
source ~/.bashrc
```

之后即可直接使用 `backup-now` 命令触发备份。


---

## 五、创建快速手动备份命令

创建快捷命令：

```bash
sudo nano /usr/local/bin/gdrive-backup
```

```bash
#!/usr/bin/env bash
set -e

show_help() {
cat <<HELP
gdrive-backup - Incremental backup to Google Drive

Usage:
  gdrive-backup <local_dir> [drive_target_dir]

Options:
  -h, --help        Show this help message

Examples:
  gdrive-backup /home/yourname/apps backup/apps
  gdrive-backup ~/documents
HELP
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

if [ $# -lt 1 ]; then
  echo "Error: missing local_dir"
  show_help
  exit 1
fi

SRC="$1"
DST="gdrive:${2:-backup}"

rclone copy "$SRC" "$DST" \
  --exclude "/.*" \
  --exclude "**/.*" \
  --progress
```

赋权：

```bash
sudo chmod +x /usr/local/bin/gdrive-backup
```

使用：

```bash
gdrive-backup /home/yourname/apps backup/apps
```

---

## 六、推荐使用方式（实践经验）

推荐采用 **三层备份策略**：

| 类型                      | 用途         |
| ----------------------- | ---------- |
| systemd timer           | 每日自动备份     |
| systemctl start service | 立即执行一次自动备份 |
| gdrive-backup           | 手动备份任意目录   |

例如：

```bash
## 立即执行定时备份
sudo systemctl start rclone-gdrive-apps-copy.service

## 手动备份某目录
gdrive-backup ~/workspace backup/workspace
```

---

## 七、总结

通过 rclone + systemd 可以快速构建一套稳定的个人备份体系：

* 自动每日备份
* 手动即时备份
* 增量同步节省带宽
* 排除隐藏文件
* 日志与并发保护

这种方式非常适合：

* 服务器代码备份
* 开发环境数据备份
* 个人长期归档



