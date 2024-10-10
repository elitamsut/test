pipeline {
  agent any
  stages {
    stage('Clone Repository') {
      steps {
        git 'git@github.com:elitamsut/test.git'
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