pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sayfops/trend-devops-app"
        EKS_CLUSTER  = "trend-cluster"
        AWS_REGION   = "ap-south-1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
                sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                aws eks update-kubeconfig --name ${EKS_CLUSTER} --region ${AWS_REGION}
                kubectl set image deployment/trend-app trend-app=${DOCKER_IMAGE}:${BUILD_NUMBER}
                kubectl rollout status deployment/trend-app --timeout=120s
                """
            }
        }

    }

    post {
        success {
            echo "Deployment successful — image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline failed — check logs for details"
        }
    }
}
