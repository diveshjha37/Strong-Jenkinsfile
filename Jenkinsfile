pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/diveshjha37/web-server-cd.git'
        IMAGE_NAME = 'ghcr.io/diveshjha37/securenginx'
        GITHUB_CREDENTIALS = 'ghcr-credentials'
        GITHUB_REGISTRY = 'ghcr.io'
        SONARQUBE_PROJECT_KEY = 'your-sonarqube-project-key'
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

        stage('Dependency Scanning') {
            steps {
                script {
                    sh 'snyk test'
                }
            }
        }

        stage('Check for Code Changes') {
            steps {
                script {
                    // Check for changes in the repository
                    def changes = sh(script: 'git diff --name-only HEAD^ HEAD', returnStdout: true).trim()
                    if (changes) {
                        echo "Changes detected: ${changes}"
                        env.BUILD_IMAGE = 'true'
                    } else {
                        echo "No changes detected. Skipping Docker image build."
                        env.BUILD_IMAGE = 'false'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { env.BUILD_IMAGE == 'true' }
            }
            steps {
                script {
                    docker.build("${IMAGE_NAME}")
                }
            }
        }

        stage('Docker Image Scanning') {
            when {
                expression { env.BUILD_IMAGE == 'true' }
            }
            steps {
                script {
                    sh "trivy image --exit-code 1 ${IMAGE_NAME}"
                }
            }
        }

        stage('Run Container Locally') {
            when {
                expression { env.BUILD_IMAGE == 'true' }
            }
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

        stage('Run Unit Tests') {
            steps {
                script {
                    sh 'npm test'
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                script {
                    sh 'npm run integration-tests'
                }
            }
        }

        stage('Security Testing') {
            steps {
                script {
                    sh 'some-security-testing-command'
                }
            }
        }

        stage('Performance Testing') {
            steps {
                script {
                    sh 'some-performance-testing-command'
                }
            }
        }

        stage('Push Docker Image to GitHub Container Registry') {
            when {
                expression { env.BUILD_IMAGE == 'true' }
            }
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

// Function to install packages if it fails it will abort the pipeline.
def installLintingTools() {
    def hadolintStatus = sh(script: '''
        if ! command -v hadolint &> /dev/null; then
            echo "Hadolint not found. Installing..."
            curl -sSfL https://raw.githubusercontent.com/hadolint/hadolint/master/install.sh | sh -s -- -b /usr/local/bin
        else
            echo "Hadolint is already installed."
        fi
    ''', returnStatus: true)

    if (hadolintStatus != 0) {
        error("Hadolint installation failed. Exiting pipeline.")
    }

    def htmlhintStatus = sh(script: '''
        if ! command -v htmlhint &> /dev/null; then
            echo "HTMLHint not found. Installing..."
            npm install -g htmlhint
        else
            echo "HTMLHint is already installed."
        fi
    ''', returnStatus: true)

    if (htmlhintStatus != 0) {
        error("HTMLHint installation failed. Exiting pipeline.")
    }
}
