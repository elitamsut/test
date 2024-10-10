pipeline {
  agent {
    dockerfile {
      filename 'Dockerfile'
    }

  }
  stages {
    stage('Clone Repository') {
      steps {
        git(branch: 'test', credentialsId: 'my-key', url: 'git@github.com:elitamsut/test.git')
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          app = docker.build("elitamsut/myapp:${env.BUILD_ID}", ".")
        }

      }
    }

    stage('Push Docker Image') {
      steps {
        script {
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