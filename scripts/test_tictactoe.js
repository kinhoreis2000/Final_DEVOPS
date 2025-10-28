const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

// ⭐️ MUITO IMPORTANTE: Coloque a URL do seu *Servidor de Teste* aqui
const testingServerUrl = 'http://18.215.146.69/public/index.html'; 

async function testTicTacToeX() {
    let driver = await new Builder().forBrowser('chrome').build();
    try {
        // 1. Abre a página do Jogo da Velha no servidor de teste
        await driver.get(testingServerUrl);
        
        // 2. Encontra a primeira célula (assumindo que tem id 'cell0')
        let firstCell = await driver.findElement(By.id('cell0'));
        
        // 3. Clica na célula
        await firstCell.click();
        
        // 4. Espera um pouquinho para o DOM atualizar (opcional, mas seguro)
        await driver.sleep(500); 
        
        // 5. Pega o texto DENTRO da célula clicada
        let cellText = await firstCell.getText();
        
        // 6. VERIFICA O BUG!
        // O teste vai PASSAR se o texto for '×' (o caractere 'x')
        // O teste vai FALHAR se o texto for 'player' ou qualquer outra coisa
        console.log(`Texto encontrado na célula: "${cellText}"`); // Para debug no Jenkins
        assert.strictEqual(cellText.trim(), '×', 'ERRO: A célula não mostrou "×", mostrou "' + cellText + '"!');
        
        console.log("Teste passou! O caractere 'x' foi exibido corretamente.");
        
    } finally {
        // Fecha o navegador, mesmo se o teste falhar
        await driver.quit();
    }
}

// Roda a função de teste
testTicTacToeX().catch(err => {
    console.error("O TESTE FALHOU:", err);
    process.exit(1); // Sai com código de erro para o Jenkins saber que falhou
});