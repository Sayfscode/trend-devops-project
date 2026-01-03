pipeline {
  agent any

  stages {

    stage('Clone Repo') {
      steps { checkout scm }
    }

    stage('Build Frontend') {
      steps {
        dir('Trend') {
          sh 'npm install'
          sh 'npm run build'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t sayfops/trend-devops-app:${BUILD_NUMBER} .'
      }
    }

    stage('Login DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
        }
      }
    }

    stage('Push Image') {
      steps {
        sh 'docker push sayfops/trend-devops-app:${BUILD_NUMBER}'
      }
    }
  }
}