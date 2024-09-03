#!/bin/bash

# 变量定义
FRP_VERSION="0.60.0"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
FRP_DIR="/opt/frp_${FRP_VERSION}"
CONFIG_FILE="${FRP_DIR}/frps.toml"

# 更新系统并安装必要工具
echo "更新系统并安装必要工具..."
sudo apt-get update -y && sudo apt-get install wget tar -y

# 下载并解压FRP
echo "下载FRP ${FRP_VERSION}..."
wget -qO- ${FRP_URL} | sudo tar -xz -C /opt

# 移动并重命名文件夹
sudo mv /opt/frp_${FRP_VERSION}_linux_amd64 ${FRP_DIR}

# 配置frps.toml
echo "配置 frps.toml..."
sudo tee ${CONFIG_FILE} > /dev/null <<EOL
[common]
bind_port = 7000
auth.token = "mc.apohs.org"
EOL

# 创建服务文件
echo "创建 systemd 服务文件..."
sudo tee /etc/systemd/system/frps.service > /dev/null <<EOL
[Unit]
Description=FRP Server Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=${FRP_DIR}/frps -c ${CONFIG_FILE}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# 重新加载systemd并启动frps服务
echo "启动并启用 FRP 服务..."
sudo systemctl daemon-reload
sudo systemctl enable frps
sudo systemctl start frps

# 检查服务状态
echo "FRP 服务状态："
sudo systemctl status frps --no-pager

echo "FRP 安装和配置完成。"

