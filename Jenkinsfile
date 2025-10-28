def deployToServer(String hostIP) {
    sh """
        echo "Starting deployment to ${hostIP}..."
        ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.SSH_USER}@${hostIP} "
            set -ex
            sudo yum install -y git
            sudo rm -rf /var/www/html
            sudo mkdir -p /var/www/html
            sudo chown ${env.SSH_USER}:${env.SSH_USER} /var/www/html
            git clone ${env.REPO_URL} /var/www/html
            echo 'Deployment to ${hostIP} completed successfully!'
        "
    """
}

pipeline {
    agent any

    environment {
        HOST_TESTING   = '18.215.146.69'
        HOST_PROD_1    = '34.205.20.35'
        HOST_PROD_2    = '3.84.53.23'
        REPO_URL         = 'https://github.com/kinhoreis2000/Final_DEVOPS'
        SSH_USER         = 'ec2-user'
        SSH_KEY_PATH     = '/home/ec2-user/.ssh/deployer-key.pem'
        REMOTE_TEST_DIR = '/var/www/html/scripts/selenium-tests'
    }

    stages {

        stage('Deploy to Testing Environment') {
            steps {
                echo "Starting deployment to the Testing server: ${env.HOST_TESTING}"
                deployToServer(env.HOST_TESTING)
            }
        }

        stage('Run Selenium Tests') {
            steps {
                echo "Preparing and running Selenium tests on server ${env.HOST_TESTING}..."
                // ---> CORRECTED SSH BLOCK WITH \$ ESCAPES <---
                sh """
                    ssh -i ${env.SSH_KEY_PATH} -o StrictHostKeyChecking=no ${env.SSH_USER}@${env.HOST_TESTING} "
                        set -ex
                        echo 'Installing prerequisites (unzip, xvfb)...'
                        sudo yum install -y unzip xorg-x11-server-Xvfb wget

                        echo 'Checking/Installing Node.js...'
                        if ! command -v nvm &> /dev/null; then
                            echo 'Installing NVM...'
                            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                        fi
                        # Escape \$HOME here for safety, though it might work without
                        export NVM_DIR="\\\$HOME/.nvm" 
                        # Keep the \\. for escaping the dot command
                        [ -s "\\\$NVM_DIR/nvm.sh" ] && \\. "\\\$NVM_DIR/nvm.sh" 
                        nvm install 18
                        nvm use 18

                        echo 'Checking/Installing Chrome and ChromeDriver...'
                        if ! command -v google-chrome &> /dev/null; then
                           echo 'Installing Google Chrome...'
                           wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome.rpm
                           sudo yum install -y /tmp/google-chrome.rpm
                           sudo rm /tmp/google-chrome.rpm

                           echo 'Installing ChromeDriver...'
                           # Escape shell variables \$CHROME_VERSION_FULL and \$CHROME_VERSION
                           CHROME_VERSION_FULL=\\\$(google-chrome --version) 
                           CHROME_VERSION=\\\$(echo \\\$CHROME_VERSION_FULL | cut -d ' ' -f 3 | cut -d '.' -f 1-3) 
                           
                           # Escape \$CHROME_VERSION
                           if [ -z "\\\$CHROME_VERSION" ]; then 
                               echo 'ERROR: Could not determine Chrome version.'
                               exit 1
                           fi
                           # Escape \$CHROME_VERSION
                           echo "Detected Chrome version: \\\$CHROME_VERSION" 

                           # Escape \$CHROME_DRIVER_VERSION and the \$CHROME_VERSION inside the URL
                           CHROME_DRIVER_VERSION=\\\$(curl -sS https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_\\\$CHROME_VERSION) 

                           # Escape \$CHROME_DRIVER_VERSION and \$CHROME_VERSION
                           if [ -z "\\\$CHROME_DRIVER_VERSION" ]; then 
                               echo "ERROR: Could not find ChromeDriver version for Chrome \\\$CHROME_VERSION." 
                               exit 1
                           fi
                            # Escape \$CHROME_DRIVER_VERSION
                           echo "Attempting to download ChromeDriver version: \\\$CHROME_DRIVER_VERSION" 

                            # Escape \$CHROME_DRIVER_VERSION inside the URL
                           wget -O /tmp/chromedriver_linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/\\\$CHROME_DRIVER_VERSION/linux64/chromedriver-linux64.zip 
                           
                           unzip /tmp/chromedriver_linux64.zip -d /tmp
                           sudo mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/
                           sudo chmod +x /usr/local/bin/chromedriver
                           rm /tmp/chromedriver_linux64.zip
                           rm -rf /tmp/chromedriver-linux64
                        else
                            echo 'Chrome and ChromeDriver (presumably) already installed.'
                        fi

                        echo 'Installing test dependencies (npm install)...'
                        # Use Groovy variable directly here, no escape needed
                        cd ${env.REMOTE_TEST_DIR} 
                        npm install

                        echo 'Executing test: xvfb-run node test_tictactoe.js'
                        xvfb-run --auto-servernum node test_tictactoe.js
                    "
                """
                echo "Tests completed successfully!"
            }
        }

        stage('Approval for Production') {
            steps {
                echo "Tests in the 'Testing' environment passed."
                echo "Access http://${env.HOST_TESTING}/public/index.html to verify manually."
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Tests passed and manual check OK? Approve deployment to Production?'
                }
            }
        }

        stage('Deploy to Production Environment') {
            parallel {
                stage('Deploy to Production 1') {
                    steps {
                        echo "Starting deployment to Production 1: ${env.HOST_PROD_1}"
                        deployToServer(env.HOST_PROD_1)
                    }
                }
                stage('Deploy to Production 2') {
                    steps {
                        echo "Starting deployment to Production 2: ${env.HOST_PROD_2}"
                        deployToServer(env.HOST_PROD_2)
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Deployment finished successfully!'
        }
        failure {
            echo 'THE PIPELINE FAILED!'
        }
    }
}