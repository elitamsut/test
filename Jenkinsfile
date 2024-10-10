pipeline {
    agent {
        dockerfile true // Use the default Dockerfile in the root directory
    }
    stages {
        stage('Setup SSH') {
            steps {
                script {
                    // Create .ssh directory if it doesn't exist
                    sh '''
                        mkdir -p ~/.ssh
                        echo "$SSH_KEY" > ~/.ssh/id_rsa
                        chmod 600 ~/.ssh/id_rsa
                        ssh-keyscan -H github.com >> ~/.ssh/known_hosts
                    '''
                }
            }
        }

        stage('Clone Repository') {
            steps {
                git(branch: 'test', credentialsId: 'my-key', url: 'git@github.com:elitamsut/test.git')
            }
        }

        stage('List Workspace Files') {
            steps {
                script {
                    sh 'ls -al' // List files in the current directory for debugging
                }
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
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        app.push() // Push the Docker image to Docker Hub
                    }
                }
            }
        }
    }
    environment {
        PATH = "/usr/local/bin:${env.PATH}" // Set Docker binary path
        SSH_KEY = credentials('my-key') // Assuming 'my-key' is the ID of the SSH key in Jenkins
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

