from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class PetPost(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    post_type = db.Column(db.String(20))  # 'lost' 或 'found'
    pet_type = db.Column(db.String(50))   # 动物类型（猫、狗等）
    breed = db.Column(db.String(50))      # 品种
    color = db.Column(db.String(50))      # 颜色
    gender = db.Column(db.String(10))     # 性别
    age = db.Column(db.String(20))        # 年龄
    features = db.Column(db.Text)         # 特征描述
    location = db.Column(db.String(200))  # 地点
    contact = db.Column(db.String(100))   # 联系方式
    image_path = db.Column(db.String(200))# 图片路径
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(20), default='active')  # active/matched/closed
    wechat_user_id = db.Column(db.String(100))  # 微信用户ID

class ImageRecognitionResult(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('pet_post.id'))
    text_content = db.Column(db.Text)      # OCR识别出的文本内容
    detected_features = db.Column(db.Text)  # 识别出的特征
    confidence_score = db.Column(db.Float)  # 识别置信度
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class PetMatch(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    lost_post_id = db.Column(db.Integer, db.ForeignKey('pet_post.id'))
    found_post_id = db.Column(db.Integer, db.ForeignKey('pet_post.id'))
    match_score = db.Column(db.Float)       # 匹配度分数
    status = db.Column(db.String(20))       # pending/confirmed/rejected
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
