pipeline {
    agent any
    environment {
        PATH = "/usr/local/bin:${env.PATH}" // Set Docker binary path
    }
    stages {
        stage('Clone Repository') {
            steps {
                // Cloning the repository using the private RSA key for authentication
                git(branch: 'test', credentialsId: 'my-key', url: 'git@github.com:elitamsut/test.git')
            }
        }
        stage('Verify Docker Installation') {
            steps {
                script {
                    sh 'docker --version' // Verify Docker installation
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    app = docker.build("elitamsut/myapp:${env.BUILD_ID}", ".") // Build the Docker image
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    // Push the Docker image to Docker Hub using the specified credentials
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        app.push() // Push the Docker image to Docker Hub
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully!' // Success message
        }
        failure {
            echo 'Pipeline failed. Please check the logs.' // Failure message
        }
    }
}

