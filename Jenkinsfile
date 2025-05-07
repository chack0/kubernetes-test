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
                    echo "--- Build and Push Docker Image ---"
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageNameWithTag = "${env.DOCKER_IMAGE_NAME}:${gitCommit}"
                    echo "===youre Here===="
                    echo "Value of : [${env.DOCKER_IMAGE_NAME}:${gitCommit}]"
                    
                    // Set env.IMAGE_TAG directly in the Groovy script
                    // env.IMAGE_TAG = imageNameWithTag
                    // echo "Git Commit: ${gitCommit}"
                    // echo "Image Name with Tag: ${imageNameWithTag}"
                    // echo "Value of env.IMAGE_TAG after setting: [${env.IMAGE_TAG}]"

                    sh "docker build -t ${imageNameWithTag} -f ${env.DOCKERFILE_PATH} ."
                    withDockerRegistry(credentialsId: "${env.DOCKER_REGISTRY_CRED_ID}") {
                        sh "docker push ${imageNameWithTag}"
                    }

                    // echo "Value of env.IMAGE_TAG before writeFile: [${env.IMAGE_TAG}]"
                    // Stash the IMAGE_TAG
                    // writeFile file: 'image_tag.txt', text: env.IMAGE_TAG
                    writeFile file: 'image_tag.txt', text: imageNameWithTag
                    stash name: 'IMAGE_TAG_VALUE', includes: 'image_tag.txt'
                    // echo "Stashed IMAGE_TAG with value: [${env.IMAGE_TAG}]"
                    echo "--- End Build and Push Docker Image ---"
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
                    echo "Unstashed IMAGE_TAG_VALUE"
                    echo "--- image tag value using READ : [${readFile 'image_tag.txt'}]"
                    def newImage = readFile 'image_tag.txt'
                    echo "Value of newImage (from file): [${newImage}]" // Checking the read value
                    env.IMAGE_TAG_FROM_FILE = newImage // Setting another env var for extra check
                    echo "Value of env.IMAGE_TAG_FROM_FILE: [${env.IMAGE_TAG_FROM_FILE}]"

                    def deploymentFile = "${env.K8S_DEPLOYMENT_FILE}"
                    def deploymentContent = readFile(deploymentFile)
                    def updatedContent = deploymentContent.replaceAll(/(?m)^image: .*/, "image: ${newImage}")
                    writeFile file: deploymentFile, text: updatedContent

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