// Função helper para deploy (sem mudanças)
def deployParaServidor(String hostIP) {
    sh """
        echo "Iniciando deploy para ${hostIP}..."
        ssh -i ${env.CAMINHO_CHAVE_SSH} -o StrictHostKeyChecking=no ${env.USUARIO_SSH}@${hostIP} "
            sudo yum install -y git
            sudo rm -rf /var/www/html
            sudo mkdir -p /var/www/html
            sudo chown ${env.USUARIO_SSH}:${env.USUARIO_SSH} /var/www/html
            git clone ${env.REPO_URL} /var/www/html
            echo 'Deploy em ${hostIP} concluído com sucesso!'
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
        USUARIO_SSH      = 'ec2-user'
        CAMINHO_CHAVE_SSH = '/home/ec2-user/.ssh/DevOps.pem'
        // ---> NOVO: Caminho para os testes DENTRO do servidor de teste <---
        TEST_DIR_REMOTO = '/var/www/html/scripts/selenium-tests' 
    }

    stages {
        
        stage('Deploy em Ambiente de Teste') {
            steps {
                echo "Iniciando deploy para o servidor de Teste: ${env.HOST_TESTING}"
                deployParaServidor(env.HOST_TESTING)
            }
        }
        
        stage('Rodar Testes (Selenium)') { // ---> ESTÁGIO DE VOLTA! <---
            steps {
                echo "Preparando e rodando testes de Selenium no servidor ${env.HOST_TESTING}..."
                
                sh """
                    # Conecta ao servidor de TESTE para rodar os comandos
                    ssh -i ${env.CAMINHO_CHAVE_SSH} -o StrictHostKeyChecking=no ${env.USUARIO_SSH}@${env.HOST_TESTING} "
                        
                        # 1. Instala NVM e Node.js (se não tiver)
                        echo 'Verificando/Instalando Node.js...'
                        if ! command -v nvm &> /dev/null; then
                            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                            export NVM_DIR="\$HOME/.nvm"
                            [ -s "\$NVM_DIR/nvm.sh" ] && \\. "\$NVM_DIR/nvm.sh"
                        else
                            export NVM_DIR="\$HOME/.nvm"
                            [ -s "\$NVM_DIR/nvm.sh" ] && \\. "\$NVM_DIR/nvm.sh"
                        fi
                        nvm install 18
                        
                        # ---> IMPORTANTE: Instala o Chrome e o ChromeDriver <---
                        # (Necessário para o Selenium rodar)
                        echo 'Verificando/Instalando Chrome e ChromeDriver...'
                        if ! command -v google-chrome &> /dev/null; then
                           # Comandos para instalar Chrome no Amazon Linux 2 (pode variar em outros Linux)
                           curl https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -o google-chrome.rpm
                           sudo yum install -y ./google-chrome.rpm
                           rm google-chrome.rpm
                           # Instala o ChromeDriver (versão correspondente ao Chrome)
                           # Verifique a versão do Chrome com 'google-chrome --version' e ajuste se necessário
                           CHROME_DRIVER_VERSION=\$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE_\$(google-chrome --version | cut -d ' ' -f 3 | cut -d '.' -f 1-3))
                           curl -sS -o chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/\$CHROME_DRIVER_VERSION/chromedriver_linux64.zip
                           unzip chromedriver_linux64.zip
                           sudo mv chromedriver /usr/local/bin/ # Coloca no PATH
                           rm chromedriver_linux64.zip
                        fi

                        # 3. Entra na pasta dos testes e instala dependências do Selenium
                        echo 'Instalando dependências do teste...'
                        cd ${env.TEST_DIR_REMOTO}
                        npm install
                        
                        # 4. RODA O TESTE!
                        echo 'Executando script de teste: node test_tictactoe.js'
                        # Roda o teste com Xvfb para não precisar de tela gráfica
                        xvfb-run --auto-servernum node test_tictactoe.js 
                    "
                """
                
                echo "Testes concluídos com sucesso!" 
                // Se o script node falhar (exit 1), o Jenkins já marca o estágio como falha.
            }
        }
        
        stage('Aprovação para Produção') { 
            // Só executa se o estágio anterior ('Rodar Testes') passou
            steps {
                echo "Testes no ambiente de 'Testing' passaram."
                echo "Acesse http://${env.HOST_TESTING}/public/index.html para verificar manualmente."
                
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Testes passaram e verificação manual OK? Aprovar deploy para Produção?'
                }
            }
        }
        
        stage('Deploy em Ambiente de Produção') {
            // Só executa se a aprovação foi dada
            parallel {
                stage('Deploy para Production 1') {
                    steps {
                        echo "Iniciando deploy para Produção 1: ${env.HOST_PROD_1}"
                        deployParaServidor(env.HOST_PROD_1)
                    }
                }
                stage('Deploy para Production 2') {
                    steps {
                        echo "Iniciando deploy para Produção 2: ${env.HOST_PROD_2}"
                        deployParaServidor(env.HOST_PROD_2)
                    }
                }
            }
        }
    } // Fim dos stages

    post { // Sem mudanças
        always { echo 'Pipeline concluído.' }
        success { echo 'Deploy finalizado com sucesso!' }
        failure { echo 'O PIPELINE FALHOU!' }
    }
}