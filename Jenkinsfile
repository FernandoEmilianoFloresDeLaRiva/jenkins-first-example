pipeline {
    agent any

    environment {
        APP_NAME = 'health-api'
        REPO_URL = 'https://github.com/FernandoEmilianoFloresDeLaRiva/jenkins-first-example.git'
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    def branch = env.GIT_BRANCH
                    if (!branch) {
                        env.DEPLOY_ENV = 'none'
                        echo "No se detectó rama, no se desplegará."
                        return
                    }
                    branch = branch.replaceAll('origin/', '')
                    echo "Rama detectada: ${branch}"

                    switch(branch) {
                        case 'main':
                            env.DEPLOY_ENV = 'production'
                            env.EC2_USER = 'ubuntu'
                            env.EC2_IP = '52.200.251.120'
                            env.REMOTE_PATH = '/home/ubuntu/jenkins-first-example'
                            env.SSH_CRED_ID = 'ssh-key-ec2'
                            env.NODE_ENV = 'production'
                            break
                        case 'dev':
                            env.DEPLOY_ENV = 'development'
                            env.EC2_USER = 'ubuntu'
                            env.EC2_IP = '3.230.217.180'
                            env.REMOTE_PATH = '/home/ubuntu/jenkins-first-example'
                            env.SSH_CRED_ID = 'ssh-key-ec2'
                            env.NODE_ENV = 'development'
                            break
                        case 'qa':
                            env.DEPLOY_ENV = 'qa'
                            env.EC2_USER = 'ubuntu'
                            env.EC2_IP = '34.192.53.17'
                            env.REMOTE_PATH = '/home/ubuntu/jenkins-first-example'
                            env.SSH_CRED_ID = 'ssh-key-ec2'
                            env.NODE_ENV = 'qa'
                            break
                        default:
                            env.DEPLOY_ENV = 'none'
                            echo "No hay despliegue configurado para esta rama: ${branch}"
                    }
                }
            }
        }

        stage('Checkout') {
            when {
                expression { env.DEPLOY_ENV != 'none' }
            }
            steps {
                git branch: env.GIT_BRANCH.replaceAll('origin/', ''), url: "${REPO_URL}"
            }
        }

        stage('Build') {
            when {
                expression { env.DEPLOY_ENV != 'none' }
            }
            steps {
                sh 'rm -rf node_modules'
                sh 'npm ci'
            }
        }

        stage('Deploy') {
            when {
                expression { env.DEPLOY_ENV != 'none' }
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: env.SSH_CRED_ID, keyFileVariable: 'SSH_KEY')]) {
                    sh 'chmod +x ./deploy.sh'
                    def branchName = env.GIT_BRANCH.replaceAll('origin/', '')
                    sh """
                    SSH_KEY=\$SSH_KEY \
                    EC2_USER=\$EC2_USER \
                    EC2_IP=\$EC2_IP \
                    REMOTE_PATH=\$REMOTE_PATH \
                    REPO_URL=\$REPO_URL \
                    APP_NAME=\$APP_NAME \
                    NODE_ENV=\$NODE_ENV \
                    GIT_BRANCH=${branchName} \
                    ./deploy.sh
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Despliegue exitoso en ${env.DEPLOY_ENV}"
        }
        failure {
            echo "El despliegue en ${env.DEPLOY_ENV} ha fallado"
        }
    }
}
