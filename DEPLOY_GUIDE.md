# 宠物寻找平台部署指南

## 1. 准备工作

确保服务器上安装了以下软件：
```bash
# 更新系统包
sudo apt-get update
sudo apt-get upgrade

# 安装必要的系统包
sudo apt-get install -y python3-pip python3-venv supervisor nginx git
```

## 2. 配置 Nginx

创建 Nginx 配置文件：
```bash
sudo nano /etc/nginx/sites-available/pet_finder
```

添加以下内容：
```nginx
server {
    listen 80;
    server_name your_domain.com;  # 替换为您的域名

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 用于处理上传的图片
    location /uploads {
        alias /root/pet_finder/uploads;
    }
}
```

启用站点：
```bash
sudo ln -s /etc/nginx/sites-available/pet_finder /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 3. 配置 SSL 证书

使用 Certbot 安装 SSL 证书：
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your_domain.com
```

## 4. 部署应用

1. 克隆代码到服务器：
```bash
cd /root
git clone <你的代码仓库地址> pet_finder
cd pet_finder
```

2. 设置环境变量：
```bash
cp .env.example .env
nano .env  # 编辑配置文件，填入实际的配置信息
```

3. 运行部署脚本：
```bash
chmod +x deploy.sh
./deploy.sh
```

## 5. 检查部署状态

1. 检查 supervisor 状态：
```bash
supervisorctl status
```

2. 检查日志：
```bash
tail -f logs/access.log
tail -f logs/error.log
```

3. 检查应用是否正常运行：
```bash
curl http://localhost:8000
```

## 6. 故障排除

如果遇到问题，请检查以下日志：

1. Nginx 日志：
```bash
sudo tail -f /var/log/nginx/error.log
```

2. 应用日志：
```bash
tail -f logs/supervisor.err.log
tail -f logs/supervisor.out.log
```

3. 常见问题解决：

- 如果端口被占用：
```bash
sudo lsof -i :8000
```

- 如果需要重启应用：
```bash
supervisorctl restart pet_finder
```

- 如果需要重启 Nginx：
```bash
sudo systemctl restart nginx
```

## 7. 安全配置

1. 配置防火墙：
```bash
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
sudo ufw enable
```

2. 设置文件权限：
```bash
chmod -R 755 /root/pet_finder
chmod -R 777 /root/pet_finder/uploads
chmod -R 777 /root/pet_finder/logs
```

## 8. 维护命令

- 更新代码：
```bash
cd /root/pet_finder
git pull
supervisorctl restart pet_finder
```

- 查看日志：
```bash
tail -f logs/access.log
```

- 备份数据库：
```bash
cp pet_finder.db pet_finder.db.backup
```
