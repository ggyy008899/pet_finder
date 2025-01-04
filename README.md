# 宠物失踪招领平台

一个连接微信公众号的宠物失踪招领信息对接平台。

## 功能特点

- 发布宠物失踪信息
- 发布宠物寻获信息
- 信息匹配推送
- 微信公众号消息交互
- 图片上传与展示
- 位置信息展示

## 技术栈

- Python Flask
- SQLAlchemy
- WeChat SDK
- Bootstrap
- SQLite

## 安装与运行

1. 安装依赖：
```bash
pip install -r requirements.txt
```

2. 配置微信公众号参数：
在 `config.py` 中配置相关参数

3. 运行应用：
```bash
python app.py
```

## 项目结构

```
pet_finder/
├── app.py              # 应用主文件
├── config.py           # 配置文件
├── models.py           # 数据模型
├── routes.py           # 路由
├── requirements.txt    # 项目依赖
├── static/            # 静态文件
└── templates/         # 模板文件
```
