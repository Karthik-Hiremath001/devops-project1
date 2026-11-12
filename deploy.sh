#!/bin/bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-karthikops/dev:latest}"
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

echo "Pulling Docker image..."
docker pull "$IMAGE_NAME"

echo "Removing previous container..."
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

echo "Deployment completed successfully!"
EOF
