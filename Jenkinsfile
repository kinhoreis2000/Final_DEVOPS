// Esta função é um "helper". A definimos aqui para não repetir o mesmo
// script de deploy três vezes. Isso torna o pipeline muito mais limpo.
def deployParaServidor(String hostIP) {
    sh """
        echo "Iniciando deploy para ${hostIP}..."
        
        # 1. Conecta via SSH, -i usa nossa chave, -o ignora a verificação de host
        ssh -i ${env.CAMINHO_CHAVE_SSH} -o StrictHostKeyChecking=no ${env.USUARIO_SSH}@${hostIP} "
            
            # 2. Instala o git (se já tiver, não faz nada)
            sudo yum install -y git
            
            # 3. Limpa o diretório antigo e recria
            sudo rm -rf /var/www/html
            sudo mkdir -p /var/www/html
            
            # 4. Dá permissão ao nosso usuário para que o 'git clone' não precise de sudo
            sudo chown ${env.USUARIO_SSH}:${env.USUARIO_SSH} /var/www/html
            
            # 5. Clona o código mais recente do repositório para a pasta
            git clone ${env.REPO_URL} /var/www/html
            
            echo 'Deploy em ${hostIP} concluído com sucesso!'
        "
    """
}

pipeline {
    agent any

    // =========================================================================
    // ⭐️ CONFIGURE SUAS VARIÁVEIS AQUI ⭐️
    // =========================================================================
    environment {
        // --- IPs dos seus servidores EC2 ---
        HOST_TESTING   = '18.215.146.69'
        HOST_PROD_1    = '34.205.20.35'
        HOST_PROD_2    = '3.84.53.23'
        
        // --- Configuração do Repositório e SSH ---
        REPO_URL         = 'https://github.com/kinhoreis2000/Final_DEVOPS' // Ou o seu repo
        USUARIO_SSH      = 'ec2-user'
        
        // Caminho ABSOLUTO no *servidor Jenkins* onde a chave .pem está.
        // (Veja as instruções abaixo do código sobre como configurar isso)
        CAMINHO_CHAVE_SSH = '/var/lib/jenkins/.ssh/DevOps.pem'
    }

    stages {
        
        stage('Deploy em Ambiente de Teste') {
            steps {
                echo "Iniciando deploy para o servidor de Teste: ${env.HOST_TESTING}"
                // Chama nossa função helper para fazer o deploy
                deployParaServidor(env.HOST_TESTING)
            }
        }
        
        stage('Rodar Testes (Selenium)') {
            steps {
                echo "Rodando testes de Selenium contra o servidor ${env.HOST_TESTING}..."
                
                // Este script executa os testes DENTRO do servidor de teste.
                // Isso é mais robusto do que rodar no Jenkins.
                sh """
                    ssh -i ${env.CAMINHO_CHAVE_SSH} -o StrictHostKeyChecking=no ${env.USUARIO_SSH}@${env.HOST_TESTING} "
                        
                        # 1. Instala o NVM (gerenciador do Node.js)
                        echo 'Instalando Node.js e dependências...'
                        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                        
                        # 2. Ativa o NVM e instala o Node.js 18
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                        nvm install 18
                        
                        # 3. Entra na pasta de testes e instala as dependências (selenium-webdriver, etc)
                        cd /var/www/html/public/selenium-tests
                        npm install
                        
                        # 4. Finalmente, RODA O TESTE!
                        echo 'Executando script de teste...'
                        node test_form.js
                    "
                """
                
                echo "Testes concluídos com sucesso!"
            }
        }
        
        
        stage('Deploy em Ambiente de Produção') {
            // Este 'parallel' executa os deploys nos dois servidores
            // ao mesmo tempo, economizando tempo.
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

    }

    post {
        always {
            echo 'Pipeline concluído.'
        }
        success {
            echo 'Deploy finalizado com sucesso!'
        }
        failure {
            echo 'O PIPELINE FALHOU!'
        }
    }
}