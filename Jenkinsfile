pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'elitamsut/myapp' // Your Docker image name
        DOCKER_TAG = 'v1.0.9' // Specify your Docker image tag
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone your Git repository
                git credentialsId: 'my-key', url: 'git@github.com:elitamsut/test.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "--pull") // Pull latest base image
                }
            }
        }

        stage('Run Tests') {
            steps {
                // Run your tests (if you have any)
                // Modify this step based on your testing framework
                sh 'docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} python -m unittest discover -s tests'
            }
        }

        stage('Push Docker Image') {
            steps {
                // Log in to Docker Hub
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                }
                // Push the Docker image to Docker Hub
                sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }
    }

    post {
        success {
            echo 'CI Pipeline completed successfully! The Docker image has been pushed to Docker Hub.'
        }
        failure {
            echo 'CI Pipeline failed.'
        }
    }
}

