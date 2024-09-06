#!/bin/bash

# 下载并安装 frps
wget https://github.com/fatedier/frp/releases/download/v0.60.0/frp_0.60.0_linux_amd64.tar.gz || { echo "下载失败"; exit 1; }
tar -xf frp_0.60.0_linux_amd64.tar.gz || { echo "解压失败"; exit 1; }

# 创建目录并复制文件
mkdir -p /opt/frp
cp frp_0.60.0_linux_amd64/frps /opt/frp/frps
cp frp_0.60.0_linux_amd64/frps.toml /opt/frp/frps.toml
chmod +x /opt/frp/frps

# 修改配置文件：确保 bindPort 行存在并修改为 7000
if grep -q '^bindPort' /opt/frp/frps.toml; then
  sed -i 's/^bindPort.*/bindPort = 7000/' /opt/frp/frps.toml
else
  echo "bindPort = 7000" >> /opt/frp/frps.toml
fi

# 第二行添加 'auth.token = "mc.apohs.org"'
sed -i '2i auth.token = "mc.apohs.org"' /opt/frp/frps.toml

# 使用 systemd 管理 frps
cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=frps service
After=network.target

[Service]
Type=simple
ExecStart=/opt/frp/frps -c /opt/frp/frps.toml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps

# 等待并确认
sleep 5
echo "frps 安装完成"
echo "frps 启动完成"
