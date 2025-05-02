pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = 'docker.io' // Default Docker Hub registry
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker'
        IMAGE_TAG = "${env.GIT_COMMIT}" // Using Git commit SHA as tag
        DOCKERFILE_PATH = 'Dockerfile' // Dockerfile is in the root
        KUBE_MANIFESTS_REPO_URL = 'https://github.com/chack0/kubernetes-test.git'
        KUBE_MANIFESTS_PATH = 'kubernetes' // Manifests are in the 'kubernetes' directory
        DEPLOYMENT_FILE = 'deployment.yaml'
    }
    stages {
        stage('Checkout Code') {
            steps {
                git credentialsId: 'flutter-app-repo-creds', url: 'https://github.com/chack0/kubernetes-test.git'
            }
        }
        stage('Setup Flutter') {
            steps {
                sh 'flutter doctor' // Verify Flutter setup
                sh 'flutter build web --release'
            }
        }
        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "docker build -f ${DOCKERFILE_PATH} -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} ${DOCKER_REGISTRY}"
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Checkout Kubernetes Manifests') {
            steps {
                git credentialsId: 'kube-manifests-repo-creds', url: "${KUBE_MANIFESTS_REPO_URL}", branch: 'main' // Adjust branch if needed
            }
        }
        stage('Update Kubernetes Deployment Manifest') {
            steps {
                script {
                    def deploymentFile = readFile "${KUBE_MANIFESTS_PATH}/${DEPLOYMENT_FILE}"
                    def updatedDeployment = deploymentFile.replaceFirst("image: .*", "image: ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}")
                    writeFile file: "${KUBE_MANIFESTS_PATH}/${DEPLOYMENT_FILE}", text: updatedDeployment
                }
            }
        }
        stage('Commit and Push Kubernetes Manifests') {
            steps {
                script {
                    sh "git config user.email 'jenkins@example.com'"
                    sh "git config user.name 'Jenkins'"
                    sh "cd ${KUBE_MANIFESTS_PATH}"
                    sh "git add ${DEPLOYMENT_FILE}"
                    sh "git commit -m 'Update Docker image tag to ${IMAGE_TAG}'"
                    withCredentials([usernamePassword(credentialsId: 'kube-manifests-repo-creds', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) { // Assuming same credentials for checkout and push
                        sh "git push origin main" // Adjust branch if needed
                    }
                }
            }
        }
    }
    triggers {
        githubPush() // Configure webhook in your GitHub repo to trigger this pipeline
    }
}