#!/bin/bash

chmod +x monitor.sh
chmod +x uninstall.sh
chmod +x logs.sh
chmod +x restart.sh
chmod +x domain_manager.sh
# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
#while ! redis-cli -h redis ping > /dev/null 2>&1; do
#    echo "Redis is not ready yet. Retrying in 5 seconds..."
#    sleep 5
#done
echo "Redis is ready!"

# Start Gunicorn
echo "Starting Gunicorn..."
exec gunicorn --config gunicorn_config.py --log-level debug app:app
#exec gunicorn --bind 0.0.0.0:5000 --workers 2 --timeout 60 --log-level debug app:app