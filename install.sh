#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此脚本"
    exit 1
fi

if [ -x "$(command -v apt-get)" ]; then
    PM="apt-get"
    apt-get update
elif [ -x "$(command -v yum)" ]; then
    PM="yum"
elif [ -x "$(command -v dnf)" ]; then
    PM="dnf"
else
    echo "不支持的操作系统!"
    exit 1
fi

HAS_DOCKER=$(command -v docker)
HAS_DOCKER_COMPOSE=$(command -v docker-compose)

if [ -z "$HAS_DOCKER" ] || [ -z "$HAS_DOCKER_COMPOSE" ]; then
    echo "安装 Docker 和 Docker Compose..."

    for i in {1..3}; do
        curl -fsSL https://get.docker.com -o get-docker.sh
        DOWNLOAD_URL=https://mirrors.ustc.edu.cn/docker-ce sh get-docker.sh
        if [ $? -eq 0 ]; then
            rm -f get-docker.sh
            break
        else
            echo "Docker 安装失败，正在重试... ($i/3)"
            rm -f get-docker.sh
            sleep 2
        fi
    done

    if [ -z "$(command -v docker)" ] || [ -z "$(command -v docker-compose)" ]; then
        echo "Docker 安装失败，请检查网络连接或手动安装 Docker。"
        exit 1
    fi
fi

AVAILABLE_DOCKER_REGISTRY=("hub.docker.com", "docker.1ms.run")
LOWEST_LATENCY=1000000
BEST_REGISTRY="docker.1ms.run"
for REGISTRY in "${AVAILABLE_DOCKER_REGISTRY[@]}"; do
    LATENCY=$(ping -c 3 "$REGISTRY" | tail -1 | awk -F '/' '{print $5}')
    if (( $(echo "$LATENCY < $LOWEST_LATENCY" | bc -l) )); then
        LOWEST_LATENCY=$LATENCY
        BEST_REGISTRY=$REGISTRY
    fi
done

echo "选择最快的 Docker Registry: $BEST_REGISTRY"

if [ "$BEST_REGISTRY" != "hub.docker.com" ]; then
    docker pull $BEST_REGISTRY/yemaster/hustoj-web
    docker pull $BEST_REGISTRY/yemaster/hustoj-judger
    docker tag $BEST_REGISTRY/yemaster/hustoj-web yemaster/hustoj-web
    docker tag $BEST_REGISTRY/yemaster/hustoj-judger yemaster/hustoj-judger
    docker rmi $BEST_REGISTRY/yemaster/hustoj-web
    docker rmi $BEST_REGISTRY/yemaster/hustoj-judger
else
    docker pull yemaster/hustoj-web
    docker pull yemaster/hustoj-judger
fi


HAS_GIT=$(command -v git)

if [ -z "$HAS_GIT" ]; then
    echo "安装 Git..."
    $PM install -y git
fi

HAS_OPENSSL=$(command -v openssl)

if [ -z "$HAS_OPENSSL" ]; then
    echo "安装 OpenSSL..."
    $PM install -y openssl
fi

if [ ! -d "./hustoj-docker" ]; then
    echo "克隆 hustoj-docker 仓库..."
    # 尝试 3 次克隆
    for i in {1..3}; do
        git clone https://github.com/yemaster/hustoj-docker
        if [ $? -eq 0 ]; then
            break
        else
            echo "克隆失败，正在重试... ($i/3)"
            sleep 2
        fi
    done
fi

if [ ! -d "./hustoj-docker" ]; then
    echo "尝试用国内镜像克隆 hustoj-docker 仓库..."
    # 尝试 3 次克隆
    for i in {1..3}; do
        git clone https://gh-proxy.com/https://github.com/yemaster/hustoj-docker
        if [ $? -eq 0 ]; then
            GITHUB_PROXY=https://gh-proxy.com/
            break
        else
            echo "克隆失败，正在重试... ($i/3)"
            sleep 2
        fi
    done
fi

if [ ! -d "./hustoj-docker" ]; then
    echo "无法克隆 hustoj-docker 仓库，请检查网络连接。"
    exit 1
fi

cd hustoj-docker
echo "开始部署..."

cp .env.example .env

read -p "请输入 HUSTOJ 运行端口 (默认 80): " WEB_PORT
WEB_PORT=${WEB_PORT:-80}
read -p "请输入你的 OJ 名称（避免使用中文和空格，默认 DockerHustoj）: " HUSTOJ_NAME
HUSTOJ_NAME=${HUSTOJ_NAME:-DockerHustoj}

MYSQL_ROOT_PASSWORD=$(openssl rand -base64 20 | tr -dc 'a-zA-Z0-9' | head -c 20)

sed -i "s|^WEB_PORT=.*|WEB_PORT=$WEB_PORT|" .env
sed -i "s|^HUSTOJ_NAME=.*|HUSTOJ_NAME=$HUSTOJ_NAME|" .env
sed -i "s|^MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD|" .env

chmod +x ./start.sh
GITHUB_PROXY=${GITHUB_PROXY:-""} ./start.sh