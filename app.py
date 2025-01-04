from flask import Flask, request, abort, render_template, jsonify
from wechatpy import parse_message, create_reply
from wechatpy.utils import check_signature
from wechatpy.exceptions import InvalidSignatureException
from dotenv import load_dotenv
from models import db, PetPost, ImageRecognitionResult, PetMatch
from services.image_processor import create_processor
import os

# 加载环境变量
load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('FLASK_SECRET_KEY', 'dev')
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///pet_finder.db'
app.config['UPLOAD_FOLDER'] = 'uploads'

# 初始化数据库
db.init_app(app)

# 创建图像处理器
image_processor = create_processor()

# 确保上传目录存在
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# 微信公众号配置
TOKEN = os.getenv('WECHAT_TOKEN')
AES_KEY = os.getenv('WECHAT_AES_KEY')
APPID = os.getenv('WECHAT_APPID')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/upload', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': '没有上传图片'}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': '没有选择文件'}), 400
    
    # 保存图片
    filename = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(filename)
    
    try:
        # 处理图片
        results = image_processor.process_image(filename)
        
        # 创建识别结果记录
        recognition_result = ImageRecognitionResult(
            text_content=str(results['text_content']),
            detected_features=str(results['detected_features']),
            confidence_score=results['confidence_score']
        )
        db.session.add(recognition_result)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'results': results
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/wechat', methods=['GET', 'POST'])
def wechat():
    if request.method == 'GET':
        # 处理微信服务器的验证请求
        signature = request.args.get('signature', '')
        timestamp = request.args.get('timestamp', '')
        nonce = request.args.get('nonce', '')
        echostr = request.args.get('echostr', '')
        
        try:
            check_signature(TOKEN, signature, timestamp, nonce)
            return echostr
        except InvalidSignatureException:
            abort(403)
    
    # 处理微信消息
    try:
        msg = parse_message(request.data)
        if msg.type == 'image':
            # 处理图片消息
            reply = handle_image_message(msg)
        elif msg.type == 'text':
            reply = create_reply('收到您的消息：' + msg.content, msg)
        else:
            reply = create_reply('收到非文本消息', msg)
        return reply.render()
    except Exception as e:
        return 'Error: ' + str(e)

def handle_image_message(msg):
    """处理图片消息"""
    try:
        # 获取图片URL并下载
        image_url = msg.image
        # 这里需要实现图片下载逻辑
        
        # 处理图片并返回结果
        # results = image_processor.process_image(image_path)
        
        return create_reply('图片已收到并处理，请等待进一步通知', msg)
    except Exception as e:
        return create_reply('图片处理失败：' + str(e), msg)

@app.route('/api/match', methods=['POST'])
def match_pets():
    """匹配宠物信息"""
    post_id = request.json.get('post_id')
    post = PetPost.query.get_or_404(post_id)
    
    # 查找潜在匹配
    potential_matches = PetPost.query.filter(
        PetPost.id != post_id,
        PetPost.pet_type == post.pet_type,
        PetPost.status == 'active'
    ).all()
    
    matches = []
    for potential_match in potential_matches:
        score = image_processor.match_posts(post, potential_match)
        if score > 0.7:  # 匹配阈值
            matches.append({
                'post_id': potential_match.id,
                'score': score
            })
    
    return jsonify({'matches': matches})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
