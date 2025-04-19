import multiprocessing
import os

# Server socket
bind = "0.0.0.0:5000"
backlog = 2048

# Worker processes
workers = 2  # Reduced from CPU count to ensure stability
worker_class = 'sync'
worker_connections = 1000
timeout = 60  # Increased timeout
keepalive = 5
max_requests = 1000
max_requests_jitter = 50

# Logging
accesslog = '-'
errorlog = '-'
loglevel = 'debug'  # Changed to debug for more information
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = 'vpnsupport'

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# SSL
keyfile = None
certfile = None

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# Worker settings
preload_app = False  # Changed to False to ensure proper initialization
reload = False
reload_extra_files = []
reload_engine = 'auto'

# Error handling
graceful_timeout = 120
forwarded_allow_ips = '*'