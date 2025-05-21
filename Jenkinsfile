pipeline {
    agent any

    environment {
        // Environment variables
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'harris/jenkinsrepo'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        KUBERNETES_NAMESPACE = 'default'
        APP_NAME = 'react-frontend'
        HELM_CHART_PATH = './helm-chart'

        // Git repository info
        GIT_REPO_URL = 'https://github.com/Harrisjayakumar/Devops_Finalproject'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${GIT_BRANCH}",
                    credentialsId: 'github_seccred',
                    url: "${GIT_REPO_URL}"
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test -- --watchAll=false --passWithNoTests'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'docker', variable: 'DOCKER_HUB_TOKEN')]) {
                    sh """
                        echo ${DOCKER_HUB_TOKEN} | docker login ${DOCKER_REGISTRY} -u kirubarp --password-stdin
                        docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes with Helm') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh """
                        helm upgrade --install ${APP_NAME} ${HELM_CHART_PATH} \
                          --namespace ${KUBERNETES_NAMESPACE} --create-namespace \
                          --set image.repository=${DOCKER_IMAGE_NAME} \
                          --set image.tag=${DOCKER_IMAGE_TAG}
                        
                        kubectl rollout status deployment/${APP_NAME} -n ${KUBERNETES_NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ React app deployment successful!'
        }
        failure {
            echo '❌ React app deployment failed!'
        }
        always {
            sh "docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} || true"
        }
    }
}
