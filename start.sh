#!/bin/bash

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