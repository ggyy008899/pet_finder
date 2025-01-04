#!/bin/bash

# 创建 Nginx 配置
sudo tee /etc/nginx/sites-available/pet_finder << 'EOF'
server {
    listen 80;
    server_name 49.232.237.214;  # 将来替换为域名

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

# 启用站点配置
sudo ln -sf /etc/nginx/sites-available/pet_finder /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
