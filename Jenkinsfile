pipeline {
  agent any

  environment {
    IMAGE_NAME = 'sayfops/trend-devops-app'
  }

  stages {

    stage('Clone Repo') {
      steps {
        git url: 'https://github.com/Sayfscode/trend-devops-project.git', branch: 'main'
      }
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
        dir('.') {
          sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
        }
      }
    }

    stage('Login DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS')]) {
              sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
        }
      }
    }

    stage('Push Image') {
      steps {
        sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh "kubectl apply -f k8s/"
      }
    }
  }
}