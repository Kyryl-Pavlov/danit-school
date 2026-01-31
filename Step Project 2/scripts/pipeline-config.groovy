pipeline {
    agent { label 'worker-1' }
    
    environment {
        DOCKER_USER_NAME = "kyryl2b"
        IMAGE_NAME = "app-node-project"
        REGISTRY_ID = "docker-hub-creds"
    }

    stages {
        stage('1. Pull Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Kyryl-Pavlov/step-project-2.git'
            }
        }

        stage('2. Build Image') {
            steps {
                echo "Building the Docker image..."
                sh "docker build -t ${DOCKER_USER_NAME}/${IMAGE_NAME}:${env.BUILD_ID} ."
                sh "docker tag ${DOCKER_USER_NAME}/${IMAGE_NAME}:${env.BUILD_ID} ${DOCKER_USER_NAME}/${IMAGE_NAME}:latest"
            }
        }

        stage('3. Run Tests') {
            steps {
                script {
                    try {
                        echo "Starting container to run tests..."
                        sh "docker run --rm ${DOCKER_USER_NAME}/${IMAGE_NAME}:${env.BUILD_ID} npm run test"
                        echo "Tests passed successfully!"
                    } catch (Exception e) {
                        echo "Tests failed"
                        currentBuild.result = 'FAILURE'
                        error("Stopping pipeline: Tests did not pass.")
                    }
                }
            }
        }

        stage('4. Push to Docker Hub') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_ID}", 
                                                 passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                                 usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    
                    echo "Logging into Docker Hub and pushing image..."
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin"
                    sh "docker push ${DOCKER_USER_NAME}/${IMAGE_NAME}:${env.BUILD_ID}"
                    sh "docker push ${DOCKER_USER_NAME}/${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up local build images..."
            sh "docker logout"
            sh "docker rmi ${DOCKER_USER_NAME}/${IMAGE_NAME}:${env.BUILD_ID} ${DOCKER_USER_NAME}/${IMAGE_NAME}:latest || true"
        }
    }
}