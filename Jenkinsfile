pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'samarthuk/cw2-server'
        IMAGE_TAG = 'v0'
        PROD_USER = 'ubuntu' // Production server username
        PROD_HOST = '3.83.221.72' // Replace with your production server IP
        REMOTE_K8S_DIR = '/home/ubuntu/cw2-server/k8s' // Path on production server for Kubernetes YAMLs
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout the code from GitHub repository
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using the Dockerfile in the repo
                    docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                script {
                    // Run the container to test if it launches successfully
                    def container = docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").run('-d -p 8081:8081')
                    sleep 5 // Allow some time for the container to start

                    // Perform a basic test to ensure the container is up
                    sh 'curl -s http://localhost:8081 || exit 1'

                    // Stop the container after testing
                    sh 'docker stop $(docker ps -q -f ancestor=${DOCKER_IMAGE}:${IMAGE_TAG})'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
                    script {
                        // Push the image to DockerHub
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes via SSH') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'prod-ssh-key', keyFileVariable: 'KEY', usernameVariable: 'USER')]) {
                    script {
                        // SSH into the production server and deploy using kubectl
                        sh '''
                            ssh -i $KEY -o StrictHostKeyChecking=no $USER@${PROD_HOST} \
                            "sudo kubectl apply -f ${REMOTE_K8S_DIR}/deployment.yaml && sudo kubectl apply -f ${REMOTE_K8S_DIR}/service.yaml"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful — rolling update complete!"
        }
        failure {
            echo "❌ Pipeline failed. Check console output for details."
        }
    }
}
