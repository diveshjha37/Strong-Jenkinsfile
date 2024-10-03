# Jenkins Pipeline Configuration for Docker and SonarQube

This README provides step-by-step instructions for configuring a Jenkins pipeline to build a Docker image, perform static analysis, run SonarQube scans, and deploy your application. 

## Prerequisites

Before you start, ensure you have the following set up:

1. **Jenkins**:
   - A running Jenkins instance.
   - Docker installed on the Jenkins server.
   - Necessary Jenkins plugins installed:
     - **Docker Plugin**
     - **SonarQube Scanner Plugin**
     - **Pipeline Plugin**

2. **SonarQube**:
   - A running SonarQube instance.
   - A project created in SonarQube with a unique project key.

3. **GitHub Repository**:
   - A GitHub repository containing your Dockerfile and source code.

## Step 1: Configure Jenkins

1. **Add GitHub Credentials**:
   - Go to **Manage Jenkins** > **Manage Credentials**.
   - Add your GitHub credentials under **Global credentials**.

2. **Add SonarQube Server Configuration**:
   - Go to **Manage Jenkins** > **Configure System**.
   - Scroll down to the **SonarQube servers** section.
   - Add your SonarQube server details (URL and authentication token).

3. **Install Necessary Packages**:
   - Ensure that the following tools are installed on your Jenkins node:
     - Hadolint (for Dockerfile linting)
     - HTMLHint (for HTML linting)
   - You can add this as a step in your Jenkinsfile.

## Step 2: Create the Jenkinsfile

Create a `Jenkinsfile` in the root of your GitHub repository with the following content:

```groovy
pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/yourusername/yourrepo.git' // Your Git repository URL
        IMAGE_NAME = 'ghcr.io/yourusername/securenginx' // Docker image name for GitHub Container Registry
        GITHUB_CREDENTIALS = 'your-credentials-id' // Credentials ID from Jenkins global vars
        GITHUB_REGISTRY = 'ghcr.io' // GitHub Container Registry
        SONARQUBE_PROJECT_KEY = 'your-sonarqube-project-key' // SonarQube Project Key
        SONARQUBE_TOKEN = credentials('your-sonarqube-token') // SonarQube Token stored in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Install Packages') {
            steps {
                script {
                    installLintingTools()
                }
            }
        }

        stage('Static Analysis') {
            steps {
                script {
                    sh 'hadolint Dockerfile'
                    sh 'npx htmlhint index.html'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}")
                }
            }
        }

        stage('Run Container Locally') {
            steps {
                script {
                    docker.image("${IMAGE_NAME}").run("-d -p 8080:80")
                }
            }
        }

        stage('Test NGINX Setup') {
            steps {
                script {
                    sh 'curl http://localhost:8080'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    sh """
                        docker run --rm \
                        -e SONAR_HOST_URL=http://your-sonarqube-server \
                        -e SONAR_LOGIN=${SONARQUBE_TOKEN} \
                        -v \$PWD:/usr/src \
                        sonarsource/sonar-scanner-cli \
                        -Dsonar.projectKey=${SONARQUBE_PROJECT_KEY} \
                        -Dsonar.sources=.
                    """
                }
            }
        }

        stage('Push Docker Image to GitHub Container Registry') {
            steps {
                script {
                    docker.withRegistry("https://${GITHUB_REGISTRY}", "${GITHUB_CREDENTIALS}") {
                        docker.image("${IMAGE_NAME}").push()
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                script {
                    sh '''
                    ssh ubuntu@your-server "docker pull ${IMAGE_NAME} && docker stop nginx-container || true && docker rm nginx-container || true && docker run -d --name nginx-container -p 80:80 ${IMAGE_NAME}"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}

// Function to install linting tools
def installLintingTools() {
    def hadolintStatus = sh(script: '''
        if ! command -v hadolint &> /dev/null; then
            curl -sSfL https://raw.githubusercontent.com/hadolint/hadolint/master/install.sh | sh -s -- -b /usr/local/bin
        fi
    ''', returnStatus: true)
    
    if (hadolintStatus != 0) {
        error("Hadolint installation failed. Exiting pipeline.")
    }

    def htmlhintStatus = sh(script: '''
        if ! command -v htmlhint &> /dev/null; then
            npm install -g htmlhint
        fi
    ''', returnStatus: true)

    if (htmlhintStatus != 0) {
        error("HTMLHint installation failed. Exiting pipeline.")
    }
}
