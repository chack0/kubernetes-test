pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker'
        DOCKERFILE_PATH = 'Dockerfile'
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git'
        K8S_MANIFEST_REPO_CRED_ID = ''
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml'
        DOCKER_REGISTRY_CRED_ID = 'doc-id'
        IMAGE_TAG = ''
        GIT_PUSH_CREDENTIALS_ID = 'git-id'
    }

    stages {
        stage('Checkout Flutter App Code') {
            steps {
                git url: 'https://github.com/chack0/kubernetes-test.git',
                    branch: 'main'
            }
        }

        // --- IMPORTANT: This stage remains REMOVED ---
        // The Flutter web app build (flutter build web) still happens *inside* the Dockerfile.
        /*
        stage('Build Flutter Web App') {
            steps {
                sh 'git config --global --add safe.directory /opt/flutter'
                sh "${env.FLUTTER_WEB_BUILD_COMMAND}"
            }
        }
        */

        stage('Build and Push Docker Image (Standard)') { // Stage name updated for clarity
            steps {
                script {
                    echo "--- Build and Push Standard Docker Image ---"
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageNameWithTag = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                    echo "Image Name with Tag: [${imageNameWithTag}]"

                    // --- CRUCIAL: Standard Docker Build Command ---
                    sh "docker build -t ${imageNameWithTag} -f ${env.DOCKERFILE_PATH} ."

                    // --- CRUCIAL: Standard Docker Push Command ---
                    withDockerRegistry(credentialsId: "${env.DOCKER_REGISTRY_CRED_ID}") {
                        sh "docker push ${imageNameWithTag}"
                    }
                    // --- END CRUCIAL CHANGES ---

                    writeFile file: 'image_tag.txt', text: imageNameWithTag
                    stash name: 'IMAGE_TAG_VALUE', includes: 'image_tag.txt'
                    echo "--- End Build and Push Standard Docker Image ---"
                }
            }
        }
        
        stage('Checkout Kubernetes Manifests') {
            steps {
                git url: "${env.K8S_MANIFEST_REPO_URL}",
                    branch: 'main',
                    changelog: false,
                    poll: false
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    echo "--- Update Kubernetes Manifests ---"
                    unstash name: 'IMAGE_TAG_VALUE'
                    def newImage = readFile 'image_tag.txt'
                    echo "New Image Tag: ${newImage}"

                    def deploymentFile = "${env.K8S_DEPLOYMENT_FILE}"
                    echo "Deployment File Path: ${deploymentFile}"

                    def deploymentContent = readFile(deploymentFile)
                    echo "--- Deployment File Content BEFORE Update ---"
                    echo "${deploymentContent}"

                    def updatedContent = deploymentContent.replaceAll(/(?m)^ *image: *.*\r?\n/, "          image: ${newImage}\n")

                    writeFile file: deploymentFile, text: updatedContent
                    echo "--- Deployment File Content AFTER Update ---"
                    def updatedDeploymentContent = readFile(deploymentFile)
                    echo "${updatedDeploymentContent}"

                    sh 'git config --global user.email "jenkins@example.com"'
                    sh 'git config --global user.name "Jenkins"'
                    sh "git add ${deploymentFile}"
                    sh "git commit -m 'Update image tag to ${newImage}'"

                    echo "--- End Update Kubernetes Manifests ---"
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