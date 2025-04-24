pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'samarthuk/cw2-server'
        IMAGE_TAG = 'v0'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                script {
                    def container = docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").run('-d -p 8081:8081')
                    sleep 5
                    sh 'curl -s http://localhost:8081 || exit 1'
                    sh 'docker stop $(docker ps -q -f ancestor=${DOCKER_IMAGE}:${IMAGE_TAG})'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
                    script {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful — rolling update complete!"
        }
        failure {
            echo "Pipeline failed. Check console output for details."
        }
    }
}
