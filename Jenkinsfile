pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
        }
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone the GitHub repository using SSH with credentials
                git branch: 'test',
                    credentialsId: 'my-key',
                    url: 'git@github.com:elitamsut/test.git'
            }
        }

        stage('Verify Docker Installation') {
            steps {
                script {
                    // Verify Docker installation
                    sh 'docker --version'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with a unique tag based on the build ID
                    app = docker.build("elitamsut/myapp:${env.BUILD_ID}", ".")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Push the built Docker image to Docker Hub using credentials
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        app.push()
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}

