#!/bin/bash

# 创建必要的目录
mkdir -p logs
mkdir -p uploads

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 初始化数据库
python -c "from app import app, db; app.app_context().push(); db.create_all()"

# 启动 supervisor
supervisord -c supervisor.conf

echo "部署完成！"
