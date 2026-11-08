#!/bin/bash

set -euo pipefail

IMAGE_NAME="karthikops/dev:latest"
CONTAINER_NAME="devops-react-app"

if [ -z "${EC2_HOST:-}" ]; then
    echo "Error: EC2_HOST is not set."
    exit 1
fi

echo "Deploying $IMAGE_NAME to $EC2_HOST"

ssh "$EC2_HOST" bash -s -- "$IMAGE_NAME" "$CONTAINER_NAME" <<'EOF'
set -euo pipefail

IMAGE_NAME="$1"
CONTAINER_NAME="$2"

echo "Pulling latest image..."
docker pull "$IMAGE_NAME"

echo "Removing previous container if it exists..."
if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    docker rm -f "$CONTAINER_NAME"
fi

echo "Starting application..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p 80:80 \
    "$IMAGE_NAME"

echo "Checking container status..."
docker ps --filter "name=$CONTAINER_NAME"
EOF

echo "Deployment completed successfully!"#!/bin/bash

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
