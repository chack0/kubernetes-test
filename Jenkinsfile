pipeline {
    agent any // Running directly on the Jenkins master pod

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker' // From old Jenkinsfile
        DOCKERFILE_PATH = 'Dockerfile' // Assuming your Dockerfile is at the root
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git' // From old Jenkinsfile
        K8S_MANIFEST_REPO_CRED_ID = 'git-id' // Assuming you want to use this credential for manifest repo as well
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml' // From old Jenkinsfile
        DOCKER_REGISTRY_CRED_ID = 'doc-id' // From old Jenkinsfile
        IMAGE_TAG = '' // Will be set dynamically
        FLUTTER_WEB_BUILD_COMMAND = 'flutter build web --release' // Using release build
        GIT_PUSH_CREDENTIALS_ID = 'git-id' // Using the same Git credential for pushing manifests
    }


    stages {
        stage('Checkout Flutter App Code') {
            steps {
                git url: 'https://github.com/chack0/kubernetes-test.git',
                    credentialsId: 'git-id',
                    branch: 'main'
            }
        }

        stage('Build Flutter Web App') {
            steps {
                sh "${env.FLUTTER_WEB_BUILD_COMMAND}"
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.IMAGE_TAG = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                    sh "docker build -t ${env.IMAGE_TAG} -f ${env.DOCKERFILE_PATH} ."
                    withRegistry credentialsId: "${env.DOCKER_REGISTRY_CRED_ID}", url: 'https://index.docker.io/v1/' {
                        sh "docker push ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Checkout Kubernetes Manifests') {
            steps {
                git url: "${env.K8S_MANIFEST_REPO_URL}",
                    credentialsId: "${env.K8S_MANIFEST_REPO_CRED_ID}",
                    branch: 'main',
                    changelog: false,
                    poll: false
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    def newImage = env.IMAGE_TAG
                    sh "sed -i 's#image: .*#image: ${newImage}#' ${env.K8S_DEPLOYMENT_FILE}"

                    sh 'git config --global user.email "jenkins@example.com"'
                    sh 'git config --global user.name "Jenkins"'
                    sh "git add ${env.K8S_DEPLOYMENT_FILE}"
                    sh "git commit -m 'Update image tag to ${newImage}'"
                }
            }
        }

        stage('Push Kubernetes Manifests') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${env.GIT_PUSH_CREDENTIALS_ID}", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh "git push origin HEAD"
                }
            }
        }
    }
}