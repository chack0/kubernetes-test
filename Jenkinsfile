pipeline {
    agent {
        kubernetes {
            label 'test-flutter-agent' // Keep the same label for the agent
        }
    }

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker'
        DOCKERFILE_PATH = 'Dockerfile' // Should point to your self-contained Dockerfile
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git'
        K8S_MANIFEST_REPO_CRED_ID = '' // Assuming public repo for manifests
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml'
        DOCKER_REGISTRY_CRED_ID = 'doc-id' // Your Docker Hub credentials ID
        DOCKER_IMAGE_TAG = '' // Will be set during build
    }

    stages {
        stage('Checkout Flutter App Code') {
            steps {
                git url: 'https://github.com/chack0/kubernetes-test.git',
                    credentialsId: 'git-id',
                    branch: 'main'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container('jnlp') { // Use the 'jnlp' container for building
                    script {
                        def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        env.DOCKER_IMAGE_TAG = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                        sh "docker build -t ${env.DOCKER_IMAGE_TAG} -f ${env.DOCKERFILE_PATH} ."
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