// Testing Jenkins build trigger
pipeline {
  agent {
    dockerfile {
      filename 'ww' // Specify the Dockerfile to use
    }
  }
  stages {
    stage('Clone Repository') {
      steps {
        git(branch: 'test', credentialsId: 'my-key', url: 'git@github.com:elitamsut/test.git') // Clone the Git repository
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
          // Build the Docker image with a tag based on the Jenkins build ID
          app = docker.build("elitamsut/myapp:${env.BUILD_ID}", ".") 
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          // Push the Docker image to Docker Hub using specified credentials
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
            app.push() // Push the Docker image to Docker Hub
          }
        }
      }
    }
  }
  environment {
    PATH = "/usr/local/bin:${env.PATH}" // Set Docker binary path
  }
  post {
    success {
      echo 'Pipeline completed successfully!' // Message on successful pipeline completion
    }

    failure {
      echo 'Pipeline failed. Please check the logs.' // Message on pipeline failure
    }
  }
}

