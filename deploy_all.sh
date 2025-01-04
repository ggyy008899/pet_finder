#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 输出带颜色的信息
info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# 检查命令是否执行成功
check_result() {
    if [ $? -ne 0 ]; then
        error "$1 失败"
        exit 1
    else
        info "$1 成功"
    fi
}

# 1. 更新系统并安装必要的软件
info "开始更新系统并安装必要的软件..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv supervisor nginx git
check_result "系统更新和软件安装"

# 2. 创建项目目录
info "创建项目目录..."
sudo mkdir -p /var/www/pet_finder
sudo chown ubuntu:ubuntu /var/www/pet_finder
check_result "创建项目目录"

# 3. 克隆代码
info "克隆代码..."
cd /var/www/pet_finder
git clone https://github.com/ggyy008899/pet_finder.git .
check_result "代码克隆"

# 4. 创建并激活虚拟环境
info "设置Python虚拟环境..."
python3 -m venv venv
source venv/bin/activate
check_result "虚拟环境创建"

# 5. 安装项目依赖
info "安装项目依赖..."
pip install -r requirements.txt
check_result "依赖安装"

# 6. 创建必要的目录
info "创建上传和日志目录..."
mkdir -p logs uploads
sudo chown -R ubuntu:ubuntu /var/www/pet_finder
sudo chmod -R 755 /var/www/pet_finder
sudo chmod -R 777 /var/www/pet_finder/uploads
sudo chmod -R 777 /var/www/pet_finder/logs
check_result "目录创建和权限设置"

# 7. 配置 Nginx
info "配置 Nginx..."
sudo tee /etc/nginx/sites-available/pet_finder << 'EOF'
server {
    listen 80;
    server_name 49.232.237.214;  # 服务器IP

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static {
        alias /var/www/pet_finder/static;
    }

    location /uploads {
        alias /var/www/pet_finder/uploads;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/pet_finder /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
check_result "Nginx 配置"

# 8. 配置 Supervisor
info "配置 Supervisor..."
sudo tee /etc/supervisor/conf.d/pet_finder.conf << 'EOF'
[program:pet_finder]
directory=/var/www/pet_finder
command=/var/www/pet_finder/venv/bin/gunicorn -c gunicorn_config.py app:app
autostart=true
autorestart=true
stderr_logfile=/var/www/pet_finder/logs/supervisor.err.log
stdout_logfile=/var/www/pet_finder/logs/supervisor.out.log
environment=PYTHONPATH="/var/www/pet_finder"

[supervisord]
logfile=/var/www/pet_finder/logs/supervisord.log
logfile_maxbytes=50MB
logfile_backups=10
loglevel=info
pidfile=/var/www/pet_finder/supervisord.pid
EOF

sudo supervisorctl reread
sudo supervisorctl update
check_result "Supervisor 配置"

# 9. 启动服务
info "启动服务..."
sudo systemctl restart nginx
sudo supervisorctl restart pet_finder
check_result "服务启动"

# 10. 配置防火墙
info "配置防火墙..."
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
sudo ufw --force enable
check_result "防火墙配置"

# 11. 检查服务状态
info "检查服务状态..."
echo "Nginx 状态："
sudo systemctl status nginx | grep Active
echo "Supervisor 状态："
sudo supervisorctl status pet_finder

info "部署完成！"
echo "您现在可以通过以下地址访问您的应用："
echo "http://49.232.237.214"
echo ""
echo "查看应用日志："
echo "tail -f /var/www/pet_finder/logs/supervisor.err.log"
echo "tail -f /var/www/pet_finder/logs/supervisor.out.log"
