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
    // ⭐️ SUAS VARIÁVEIS JÁ ESTÃO CONFIGURADAS ⭐️
    // =========================================================================
    environment {
        // --- IPs dos seus servidores EC2 ---
        HOST_TESTING   = '18.215.146.69'
        HOST_PROD_1    = '34.205.20.35'
        HOST_PROD_2    = '3.84.53.23'
        
        // --- Configuração do Repositório e SSH ---
        REPO_URL         = 'https://github.com/kinhoreis2000/Final_DEVOPS' // Ou o seu repo
        USUARIO_SSH      = 'ec2-user'
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
        
        // ====> REMOVEMOS O ESTÁGIO DE TESTE DAQUI <====
        
        stage('Aprovação para Produção') { // ====> ADICIONAMOS ESTE ESTÁGIO <====
            steps {
                echo "Deploy em Teste concluído."
                // --> IMPORTANTE: Verifique se o caminho /public/ está correto para o seu projeto <--
                echo "Acesse http://${env.HOST_TESTING}/public/index.html para verificar o Jogo da Velha." 
                
                // Pausa o pipeline e espera por uma confirmação humana.
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'O Jogo da Velha está funcionando em Teste? Aprovar deploy para Produção?'
                }
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

    } // Fim dos stages

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