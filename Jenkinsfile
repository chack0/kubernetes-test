pipeline {
    agent {
        docker {
            image 'docker/agent:latest' // Using the official Flutter stable image
            args '-u root' // Run container as root to avoid potential permission issues
        }
    }

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker'
        DOCKERFILE_PATH = 'Dockerfile'
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git'
        K8S_MANIFEST_REPO_CRED_ID = '' // Assuming public repo for manifests
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml'
        DOCKER_REGISTRY_CRED_ID = 'doc-id' // Your Docker Hub credentials ID
    }

    stages {
        stage('Checkout Flutter App Code') {
            steps {
                git(url: 'https://github.com/chack0/kubernetes-test.git',
                    credentialsId: 'git-id', // Your GitHub token credential ID
                    branch: 'main')
            }
        }

        stage('Flutter Build') {
            steps {
                sh 'flutter clean'
                sh 'flutter pub get'
                sh 'flutter build web --release'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                    docker.build(imageTag, '.')
                    docker.withRegistry('https://index.docker.io/v1/', "${env.DOCKER_REGISTRY_CRED_ID}") {
                        docker.image(imageTag).push()
                    }
                    env.DOCKER_IMAGE_TAG = imageTag
                }
            }
        }

        stage('Checkout Kubernetes Manifests') {
            steps {
                git(url: "${env.K8S_MANIFEST_REPO_URL}",
                    credentialsId: "${env.K8S_MANIFEST_REPO_CRED_ID}",
                    branch: 'main',
                    changelog: false,
                    poll: false)
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    def newImage = env.DOCKER_IMAGE_TAG
                    sh "sed -i 's#image: .*#image: ${newImage}#' ${env.K8S_DEPLOYMENT_FILE}"

                    sh 'git config --global user.email "jenkins@example.com"'
                    sh 'git config --global user.name "Jenkins"'
                    sh "git add ${env.K8S_DEPLOYMENT_FILE}"
                    sh "git commit -m 'Update image tag to ${newImage}'"
                    sh "git push origin HEAD"
                }
            }
        }
    }
}