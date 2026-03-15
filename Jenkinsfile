pipeline {
    agent any

    environment {
        APP_NAME        = 'devops-demo-app'
        DOCKER_IMAGE    = "vishwasekar43/${APP_NAME}"
        DOCKER_REGISTRY = 'https://registry.hub.docker.com'
        AWS_REGION      = 'ap-south-1'
        EKS_CLUSTER     = 'devops-demo-cluster'
        SONAR_PROJECT   = 'devops-demo-app'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                checkout scm
                sh 'git log --oneline -5'
            }
        }

        stage('Code Quality — SonarQube') {
            steps {
                echo '🔍 Running SonarQube code quality scan...'
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT} \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=${SONAR_HOST_URL}
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '✅ Waiting for SonarQube Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                    dockerImage.tag('latest')
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing image to Docker Hub...'
                script {
                    docker.withRegistry(DOCKER_REGISTRY, 'docker-hub-credentials') {
                        dockerImage.push("${BUILD_NUMBER}")
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                echo '🚀 Deploying to Dev environment...'
                sh '''
                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name ${EKS_CLUSTER}
                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -n dev
                    kubectl rollout status deployment/${APP_NAME} -n dev
                '''
            }
        }

        stage('Run Integration Tests') {
            steps {
                echo '🧪 Running integration tests...'
                sh '''
                    kubectl wait --for=condition=ready pod \
                        -l app=${APP_NAME} \
                        -n dev \
                        --timeout=120s
                    curl -f http://$(kubectl get svc ${APP_NAME} \
                        -n dev \
                        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/health
                '''
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo '🔄 Deploying to Staging environment...'
                sh '''
                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -n staging
                    kubectl rollout status deployment/${APP_NAME} -n staging
                '''
            }
        }

        stage('Approval — Production') {
            steps {
                echo '⏳ Waiting for production approval...'
                timeout(time: 30, unit: 'MINUTES') {
                    input message: 'Deploy to Production?',
                          ok: 'Yes, deploy now',
                          submitter: 'admin,devops-lead'
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                echo '🟢 Deploying to Production...'
                sh '''
                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -n production
                    kubectl rollout status deployment/${APP_NAME} -n production
                    echo "✅ Production deployment successful!"
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
            slackSend(
                channel: '#devops-alerts',
                color: 'good',
                message: "✅ ${APP_NAME} Build #${BUILD_NUMBER} deployed to production successfully!"
            )
        }
        failure {
            echo '❌ Pipeline failed!'
            slackSend(
                channel: '#devops-alerts',
                color: 'danger',
                message: "❌ ${APP_NAME} Build #${BUILD_NUMBER} failed at stage: ${STAGE_NAME}"
            )
        }
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
        }
    }
}
