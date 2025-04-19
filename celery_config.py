from celery import Celery
from config import Config
import os

# Initialize Celery
celery = Celery('vpn_tasks',
                broker=os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0'),
                backend=os.getenv('CELERY_RESULT_BACKEND', 'redis://localhost:6379/0'))

# Configure Celery
celery.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutes
    worker_max_tasks_per_child=1,  # Restart worker after each task
    broker_connection_retry_on_startup=True
)