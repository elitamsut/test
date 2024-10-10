// Testing Jenkins build trigger

pipeline {
  agent {
    dockerfile {
      filename 'ww'
    }

  }
  stages {
    stage('Clone Repository') {
      steps {
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
      echo 'Pipeline completed successfully!'
    }

    failure {
      echo 'Pipeline failed. Please check the logs.'
    }

  }
}
