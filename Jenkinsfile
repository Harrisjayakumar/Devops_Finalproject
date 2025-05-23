pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'harrisjayakumar/jenkinsrepo'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        KUBERNETES_NAMESPACE = 'default'
        APP_NAME = 'react-frontend'
        HELM_CHART_PATH = './helm-chart'
        GIT_REPO_URL = 'https://github.com/Harrisjayakumar/Devops_Finalproject'
        GIT_BRANCH = 'main'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${GIT_BRANCH}",
                    credentialsId: 'github_seccred',
                    url: "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes with Helm') {
            steps {
                sh '''
                    helm upgrade --install $APP_NAME $HELM_CHART_PATH \
                      --namespace $KUBERNETES_NAMESPACE --create-namespace \
                      --set image.repository=$DOCKER_IMAGE_NAME \
                      --set image.tag=$DOCKER_IMAGE_TAG

                    kubectl rollout status deployment/$APP_NAME -n $KUBERNETES_NAMESPACE
                '''
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
            script {
                sh '''
                    if docker images $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG | grep $DOCKER_IMAGE_TAG; then
                        docker rmi $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG || true
                    fi
                '''
            }
        }
    }
}
