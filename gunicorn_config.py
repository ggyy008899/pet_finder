import multiprocessing

# 监听地址和端口
bind = "0.0.0.0:8000"

# 工作进程数
workers = multiprocessing.cpu_count() * 2 + 1

# 工作模式
worker_class = 'gevent'

# 最大客户端并发数量
worker_connections = 1000

# 进程名称
proc_name = 'pet_finder'

# 进程超时时间
timeout = 30

# 日志配置
accesslog = 'logs/access.log'
errorlog = 'logs/error.log'
loglevel = 'info'
