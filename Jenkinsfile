
pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        DOCKER_IMAGE = 'karthikops/prod'
        DOCKER_CREDENTIALS = 'dockerhub-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
                sh 'docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    docker logout
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=accept-new ec2-user@98.80.6.203 'bash -s' <<'EOF'
set -e

IMAGE="karthikops/prod:latest"
CONTAINER="devops-react-app"

echo "Pulling production image..."
docker pull "$IMAGE"

echo "Removing old container..."
docker rm -f "$CONTAINER" 2>/dev/null || true

echo "Starting new production container..."
docker run -d \
    --name "$CONTAINER" \
    --restart unless-stopped \
    -p 80:80 \
    "$IMAGE"

echo "Checking deployment..."
docker ps --filter "name=$CONTAINER"

echo "Production deployment completed!"
EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Production image built, pushed and deployed successfully!'
        }
        failure {
            echo 'Production pipeline failed. Check the stage logs.'
        }
    }
}
