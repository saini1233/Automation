pipeline {
    agent any
    
    // Define variables for the image, container names, and port number
    environment {
        IMAGE_NAME = 'myapp12345:latest'
        CONTAINER_NAME = 'promo12'
        PORT_NO = '8102' // Define the port number variable
        REPO_URL = 'https://github.com/saini1233/Automation.git' // Replace with your repo URL
        BRANCH_NAME = 'main' // Specify the branch name here
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                script {
                    // Checkout the specified branch from the Git repository
                    git branch: "${BRANCH_NAME}", url: "${REPO_URL}"
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    // Build the Docker image using the current directory (where the Jenkinsfile is located)
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    // Run a container to test if index.html exists
                    sh "docker run --rm ${IMAGE_NAME} cat /var/www/html/index.html"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    // Run the container and start Apache
                    sh "docker run -itd -p ${PORT_NO}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME} /bin/bash"
                    sh "docker exec ${CONTAINER_NAME} systemctl start apache2"
                    sh "docker exec ${CONTAINER_NAME} systemctl enable apache2"
                }
            }
        }

        stage('Create Restart Pipeline') {
            steps {
                script {
                    def restartJobName = "RestartApache-${CONTAINER_NAME}"
                    
                    // Define Job DSL script for creating the restart job
                    def jobDslScript = """
                        pipelineJob('${restartJobName}') {
                            description('Pipeline to restart Apache in container ${CONTAINER_NAME}')
                            definition {
                                cps {
                                    script('''
                                        pipeline {
                                            agent any
                                            stages {
                                                stage('Approval') {
                                                    steps {
                                                        input message: 'Please approve to continue', ok: 'Approve', timeout: 5 * 60, timeoutMessage: 'Approval timed out'
                                                    }
                                                }
                                                stage('Git Checkout') {
                                                    steps {
                                                        script {
                                                            git branch: '${BRANCH_NAME}', url: '${REPO_URL}'
                                                        }
                                                    }
                                                }
                                                stage('Restart Apache') {
                                                    steps {
                                                        script {
                                                            sh 'docker exec ${CONTAINER_NAME} cp -r ./index.html /var/www/html/'
                                                            sh 'docker exec ${CONTAINER_NAME} systemctl restart apache2'
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    ''')
                                }
                            }
                        }
                    """
                    
                    // Use try-catch to handle potential failures gracefully
                    try {
                        timeout(time: 10, unit: 'MINUTES') { // Set a timeout for creating the Job DSL job
                            jobDsl(scriptText: jobDslScript)
                        }

                        echo "Created a new pipeline job: ${restartJobName}"
                    } catch (Exception e) {
                        echo "Failed to create job '${restartJobName}': ${e.message}"
                        currentBuild.result = 'UNSTABLE' // Mark build as unstable instead of failing completely
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
