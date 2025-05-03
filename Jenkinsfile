pipeline {
    agent {
        kubernetes {
            label 'flutter-agent' // Use the name you gave your pod template
        }
    }

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker'
        DOCKERFILE_PATH = 'Dockerfile'
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git'
        K8S_MANIFEST_REPO_CRED_ID = '' // Assuming public repo for manifests
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml'
        DOCKER_REGISTRY_CRED_ID = 'doc-id' // Your Docker Hub credentials ID
        DOCKER_IMAGE_TAG = '' // Initialize this here, will be set later
    }

    stages {
        stage('Checkout Flutter App Code') {
            steps {
                git url: 'https://github.com/chack0/kubernetes-test.git',
                    credentialsId: 'git-id', // Your GitHub token credential ID
                    branch: 'main'
            }
        }

        stage('Flutter Build') {
            steps {
                container('jnlp') {
                    sh 'echo "Installing necessary tools..."'
                    sh 'apt-get update'
                    sh 'apt-get install -y curl git xz-utils' // Install basic tools

                    sh 'echo "Downloading Flutter SDK..."'
                    sh 'curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_arm64-3.19.3-stable.tar.xz'

                    sh 'echo "Extracting Flutter SDK..."'
                    sh 'mkdir -p flutter'
                    sh 'tar xf flutter_linux_arm64-3.19.3-stable.tar.xz -C flutter --strip-components=1'

                    sh 'echo "Setting up Flutter environment..."'
                    sh 'export PATH="$PATH:`pwd`/flutter/bin"'
                    sh 'flutter doctor -v'

                    sh 'echo "Building Flutter web app..."'
                    sh 'flutter clean'
                    sh 'flutter pub get'
                    sh 'flutter build web --release'
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container('docker') {
                    script {
                        def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        env.DOCKER_IMAGE_TAG = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                        sh "docker build -t ${env.DOCKER_IMAGE_TAG} ."
                        withRegistry credentialsId: "${env.DOCKER_REGISTRY_CRED_ID}", url: 'https://index.docker.io/v1/' {
                            sh "docker push ${env.DOCKER_IMAGE_TAG}"
                        }
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
                container('jnlp') {
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
}