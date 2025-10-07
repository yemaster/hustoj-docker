# HUSTOJ-Docker

在 Docker 中快速部署和运行 [HUSTOJ](https://github.com/zhblue/hustoj)，一个开源的在线评测系统（Online Judge）。本项目提供了一键部署的解决方案，适用于 Linux 系统。

> [!WARNING]
>
> **Windows 用户注意**：需要在 WSL（Windows Subsystem for Linux）环境中操作，且项目目录不得位于 Windows 文件系统下（如 `/mnt/c`），否则可能因权限问题导致 C/C++ 程序无法正常判题。

## 功能特性

- 一键部署 HUSTOJ，简化安装流程
- 支持自定义 Web 端口、OJ 名称、主题和数据库密码
- 数据持久化存储，方便备份与迁移
- 支持通过 Docker Hub 或国内镜像加速部署

## 安装与使用

### 一键安装，适合新手

```bash
# Github
bash <(curl -sSL https://raw.githubusercontent.com/yemaster/hustoj-docker/refs/heads/master/install.sh)

# Github 镜像（网络不好可以选择）
bash <(curl -sSL https://gh-proxy.com/https://raw.githubusercontent.com/yemaster/hustoj-docker/refs/heads/master/install.sh)
```

### 逐步安装

#### 1. 安装 Docker

在 Linux 系统上安装 Docker 和 Docker Compose：

```bash
# Ubuntu/Debian 系统
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

宝塔面板用户：在宝塔面板的 Docker 页面直接安装 Docker 即可。

#### 2. 克隆项目并配置环境

克隆本项目并准备配置文件：

```bash
# 克隆项目
git clone https://github.com/yemaster/hustoj-docker
cd hustoj-docker

# 复制示例配置文件
cp .env.example .env
```

编辑 .env 文件，根据需求修改以下配置项：

- `WEB_PORT`：HUSTOJ 的 Web 服务端口，例如 8080。若使用反向代理（如 Nginx），可设置为内网地址，如 127.0.0.1:8080。
- `HUSTOJ_NAME`：在线评测系统的名称，例如 HUSTOJ，避免使用中文和空格。
- `HUSTOJ_THEME`：HUSTOJ 的主题，可选值参考 HUSTOJ 官方文档（默认：`syzoj`）。
- `MYSQL_ROOT_PASSWORD`：MySQL 数据库 root 用户密码，建议使用随机生成的强密码（至少 12 位，包含字母、数字和符号）。

**国内用户注意**：如果无法访问 Docker Hub，可将镜像地址替换为国内镜像源，例如：

```env
WEB_IMAGE=registry.abstrax.cn/yemaster/hustoj-web
JUDGER_IMAGE=registry.abstrax.cn/yemaster/hustoj-judger
```

#### 3. 启动项目

执行以下命令启动 HUSTOJ：

```bash
# 赋予启动脚本执行权限
chmod +x start.sh

# 首次运行项目
./start.sh
```

start.sh 默认使用 `docker-compose up -d` 启动服务。如果您的系统安装了新版 Docker Compose（独立命令），请使用以下命令启动：

```bash
docker compose up -d
```

启动后，可通过 `http://<服务器IP>:<WEB_PORT>` 访问 HUSTOJ 的 Web 界面。

## 数据管理与迁移

所有数据存储在 ./data 目录下，包含以下子目录：

- `./data/web`：Web 服务代码和配置文件
- `./data/mysql`：MySQL 数据库数据
- `./data/judger`：判题机相关数据

**迁移项目**：

1. 停止服务：docker-compose down
2. 复制 ./data 目录和 docker-compose.yml 文件到新服务器
3. 在新服务器上运行 docker-compose up -d（或 docker compose up -d）

## 常见问题

1. **如何自定义 HUSTOJ 配置？**

   - 修改 ./data/web 目录下的配置文件，具体参考 [HUSTOJ 官方文档](https://github.com/zhblue/hustoj)。

2. **如何进入数据库？**

   - 执行如下语句，然后输入 `.env` 中指定的数据库密码即可：

     ```bash
     docker exec -it hustoj_db mariadb -u root -p
     ```

     进入数据库之后，选择 `jol` 数据库

     ```bash
     use jol;
     ```

3. **怎么样让我的账号变成管理员账号？**

   - 按照 2 进入数据库，然后执行如下 SQL 语句：

     ```sql
     INSERT INTO privilege values("你的用户名", 'administrator', 'true', 'N');
     ```