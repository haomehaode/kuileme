# Docker Desktop 安装指南（macOS）

## 快速安装步骤

### 1. 下载 Docker Desktop

访问 Docker 官网下载页面：
**https://www.docker.com/products/docker-desktop/**

或者直接下载 macOS 版本：
**https://desktop.docker.com/mac/main/amd64/Docker.dmg**

### 2. 安装 Docker Desktop

1. 双击下载的 `.dmg` 文件
2. 将 Docker 图标拖拽到 Applications 文件夹
3. 打开 Applications 文件夹，找到 Docker，双击启动
4. 首次启动需要输入管理员密码
5. 等待 Docker 引擎启动完成（菜单栏会出现 Docker 图标）

### 3. 验证安装

打开终端，运行：

```bash
docker --version
docker compose version
```

如果显示版本号，说明安装成功！

### 4. 启动 Kuleme Server

安装完成后，在项目目录运行：

```bash
cd /Users/piaowuguo/Desktop/kuileme/server
./start.sh
```

## 常见问题

### Docker Desktop 无法启动
- 确保 macOS 版本 >= 10.15
- 检查系统权限设置
- 重启电脑后重试

### 命令找不到
- 确保 Docker Desktop 正在运行（菜单栏有 Docker 图标）
- 重启终端
- 如果还是找不到，可能需要手动添加到 PATH
