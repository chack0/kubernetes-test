pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  nodeSelector:
    kubernetes.io/arch: arm64
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    resources:
      requests:
        cpu: 1
        memory: 2048Mi
    volumeMounts:
    - name: jenkins-agent-volume
      mountPath: /home/jenkins/agent
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: jenkins-agent-volume
      mountPath: /home/jenkins/agent
  volumes:
  - name: jenkins-agent-volume
    emptyDir: {}
"""
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
                git(url: 'https://github.com/chack0/kubernetes-test.git',
                    credentialsId: 'git-id', // Your GitHub token credential ID
                    branch: 'main')
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
                        env.DOCKER_IMAGE_TAG = "<span class="math-inline">\{env\.DOCKER\_IMAGE\_NAME\}\:</span>{gitCommit}"
                        sh "docker build -t <span class="math-inline">\{env\.DOCKER\_IMAGE\_TAG\} \."
withRegistry\(credentialsId\: "</span>{env.DOCKER_REGISTRY_CRED_ID}", url: 'https://index.docker.io/v1/') {
                            sh "docker push <span class="math-inline">\{env\.DOCKER\_IMAGE\_TAG\}"
\}
\}
\}
\}
\}
stage\('Checkout Kubernetes Manifests'\) \{
steps \{
git\(url\: "</span>{env.K8S_MANIFEST_REPO_URL}",
                    credentialsId: "${env.K8S_MANIFEST_REPO_CRED_ID}",
                    branch: 'main',
                    changelog: false,
                    poll: false)
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                container('jnlp') {
                    script {
                        def newImage = env.DOCKER_IMAGE_TAG
                        sh "sed -i 's#image: .*#image: ${