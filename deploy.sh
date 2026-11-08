#!/bin/bash

set -e

IMAGE_NAME="karthikops/dev:latest"
CONTAINER_NAME="devops-react-app"

if [ -z "$EC2_HOST" ]; then
    echo "Error: EC2_HOST is not set."
    exit 1
fi

echo "Connecting to EC2: $EC2_HOST"

ssh "$EC2_HOST" "
    docker pull $IMAGE_NAME &&
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p 80:80 \
        $IMAGE_NAME
"

echo "Deployment completed!"
