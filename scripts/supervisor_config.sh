#!/bin/bash

# 创建 Supervisor 配置
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

# 重新加载 supervisor 配置
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart pet_finder
