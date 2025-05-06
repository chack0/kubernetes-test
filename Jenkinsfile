pipeline {
    agent any // Running directly on the Jenkins master pod

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker' // From old Jenkinsfile
        DOCKERFILE_PATH = 'Dockerfile' // Assuming your Dockerfile is at the root
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git' // From old Jenkinsfile
        K8S_MANIFEST_REPO_CRED_ID = '' // Manifest repo is public, so no credentials needed
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml' // From old Jenkinsfile
        DOCKER_REGISTRY_CRED_ID = 'doc-id' // Your Docker Hub credentials ID
        IMAGE_TAG = '' // Will be set dynamically
        FLUTTER_WEB_BUILD_COMMAND = 'flutter build web --release' // Using release build
        GIT_PUSH_CREDENTIALS_ID = 'github-https-push' // Replace with your actual credential ID
    }


    stages {
        stage('Checkout Flutter App Code') {
            steps {
                git url: 'https://github.com/chack0/kubernetes-test.git',
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
                    env.IMAGE_TAG = "${env.DOCKER_IMAGE_NAME}:${gitCommit}" // Set IMAGE_TAG as environment variable

                    echo "Building Docker image with tag: ${env.IMAGE_TAG}" // Add this line for debugging

                    sh "docker build -t ${env.IMAGE_TAG} -f ${env.DOCKERFILE_PATH} ."
                    withDockerRegistry(credentialsId: "${env.DOCKER_REGISTRY_CRED_ID}") {
                        sh "docker push ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Checkout Kubernetes Manifests') {
            steps {
                git url: "${env.K8S_MANIFEST_REPO_URL}",
                    branch: 'main',
                    credentialsId: "${env.GIT_PUSH_CREDENTIALS_ID}", // While public, good practice if it becomes private
                    changelog: false,
                    poll: false
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    echo "Value of IMAGE_TAG before sed: ${env.IMAGE_TAG}" // Keep this for debugging
                    sh "sed -i \"s#image: .*#image: ${env.IMAGE_TAG}#\" ${env.K8S_DEPLOYMENT_FILE}" // Use double quotes
                    sh 'git config --global user.email "jenkins@example.com"'
                    sh 'git config --global user.name "Jenkins"'
                    sh "git add ${env.K8S_DEPLOYMENT_FILE}"
                    sh "git commit -m 'Update image tag to ${env.IMAGE_TAG}'"
                }
            }
        }

        stage('Push Kubernetes Manifests') {
            steps {
                script {
                    def githubRepoUrl = "${env.K8S_MANIFEST_REPO_URL}"
                    def credentialsId = "${env.GIT_PUSH_CREDENTIALS_ID}"

                    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PASSWORD')]) {
                        def authenticatedRepoUrl = "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@${githubRepoUrl.substring(githubRepoUrl.indexOf('//') + 2)}"

                        sh "git remote set-url origin ${authenticatedRepoUrl}"
                        sh "git push origin HEAD"
                    }
                }
            }
        }
    }
}