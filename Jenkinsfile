pipeline {
    agent any
    
    // Define variables for the image, container names, and port number
    environment {
        IMAGE_NAME = 'myapp12345:latest'
        CONTAINER_NAME = 'promo11'
        PORT_NO = '8101' // Define the port number variable
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
                    // Create a new pipeline job for restarting Apache in the deployed container
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
                    
                    // Set a timeout for creating the Job DSL job
                    timeout(time: 05, unit: 'MINUTES') { // Adjust time as necessary
                        // Execute Job DSL to create the new job
                        jobDsl(scriptText: jobDslScript)
                    }

                    echo "Created a new pipeline job: ${restartJobName}"
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
