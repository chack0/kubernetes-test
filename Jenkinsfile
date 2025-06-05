pipeline {
    agent any // Running directly on the Jenkins master pod, or on any available agent

    environment {
        DOCKER_IMAGE_NAME = 'chackoabraham/kubetest-argo-docker'
        DOCKERFILE_PATH = 'Dockerfile' // Assuming your Dockerfile is at the root of the checked out repo
        K8S_MANIFEST_REPO_URL = 'https://github.com/chack0/kubernetes-test.git'
        K8S_MANIFEST_REPO_CRED_ID = '' // Manifest repo is public, so no credentials needed
        K8S_DEPLOYMENT_FILE = 'kubernetes/deployment.yaml'
        DOCKER_REGISTRY_CRED_ID = 'doc-id' // Your Docker Hub credentials ID
        IMAGE_TAG = '' // Will be set dynamically
        // FLUTTER_WEB_BUILD_COMMAND is no longer needed as it's part of Dockerfile
        GIT_PUSH_CREDENTIALS_ID = 'git-id' // Replace with your actual credential ID
    }


    stages {
        stage('Checkout Flutter App Code') { // This checks out your Flutter app code
            steps {
                git url: 'https://github.com/chack0/kubernetes-test.git',
                    branch: 'main'
            }
        }

        // --- REMOVED THE "Build Flutter Web App" STAGE ---
        // The Flutter build (pub get, flutter build web) will now happen INSIDE the Dockerfile
        // when the 'docker buildx build' command is executed in the next stage.


        stage('Build and Push Docker Image (Multi-Arch)') {
            steps {
                script {
                    echo "--- Build and Push Multi-Architecture Docker Image ---"
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageNameWithTag = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                    echo "Image Name with Tag: [${imageNameWithTag}]"

                    // Ensure buildx builder is available and active
                    sh 'docker buildx create --name mybuilder --use || docker buildx use mybuilder --bootstrap'

                    // Build and Push the multi-architecture image using the Dockerfile
                    withDockerRegistry(credentialsId: "${env.DOCKER_REGISTRY_CRED_ID}") {
                        sh "docker buildx build --platform linux/amd64,linux/arm64 -t ${imageNameWithTag} --push -f ${env.DOCKERFILE_PATH} ."
                    }

                    writeFile file: 'image_tag.txt', text: imageNameWithTag
                    stash name: 'IMAGE_TAG_VALUE', includes: 'image_tag.txt'
                    echo "--- End Build and Push Multi-Architecture Docker Image ---"
                }
            }
        }
        
        stage('Checkout Kubernetes Manifests') { // This re-checks out the repo for manifest updates
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

                    // Regex to match the 'image:' line with potential leading spaces
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