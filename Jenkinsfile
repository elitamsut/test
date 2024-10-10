  agent any
  stages {
    stage('Clone Repository') {
      steps {
        git 'git@github.com:elitamsut/test.git'
      }
    }
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the GitHub repository using SSH
                    git 'git@github.com:elitamsut/test.git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with a unique tag based on the build ID
                    def app = docker.build("elitamsut/myapp:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Push the built Docker image to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
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

    stage('Build Docker Image') {
      steps {
        script {
          def app = docker.build("elitamsut/myapp:${env.BUILD_ID}")
        }

      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
            app.push()
          }
        }

      }
    }

  }
}
