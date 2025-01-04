#!/bin/bash

# 安装系统依赖
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv supervisor nginx git

# 创建项目目录
sudo mkdir -p /var/www/pet_finder
sudo chown ubuntu:ubuntu /var/www/pet_finder

# 克隆代码
cd /var/www/pet_finder
git clone git@github.com:ggyy008899/pet_finder.git .

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 创建必要的目录
mkdir -p logs
mkdir -p uploads

# 设置权限
sudo chown -R ubuntu:ubuntu /var/www/pet_finder
sudo chmod -R 755 /var/www/pet_finder
sudo chmod -R 777 /var/www/pet_finder/uploads
sudo chmod -R 777 /var/www/pet_finder/logs
