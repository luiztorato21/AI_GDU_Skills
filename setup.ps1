# ================================================================
# setup.ps1 - AI GDU Skills CSDE
# Configura snippets e prompts do VS Code para usar as skills do GitHub
# ================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalando Skills CSDE no VS Code" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# URLs das skills no GitHub
$urlCodeAlign = "https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/code/CodeAlign.md"
$urlDatabaseAlign = "https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/database/DatabaseAlign.md"

# Pastas do VS Code
$codeUserDir = Join-Path $env:APPDATA "Code\User"
$snippetsDir = Join-Path $codeUserDir "snippets"
$promptsDir  = Join-Path $codeUserDir "prompts"
$settingsPath = Join-Path $codeUserDir "settings.json"
$snippetsPath = Join-Path $snippetsDir "csde.code-snippets"

# Criar pastas se nao existirem
New-Item -ItemType Directory -Path $snippetsDir -Force | Out-Null
New-Item -ItemType Directory -Path $promptsDir -Force | Out-Null

# Conteudo dos snippets do editor
$snippetContent = @"
{
  "CSDE Revisao Code": {
    "prefix": "CDU-code",
    "body": [
      "#fetch:$urlCodeAlign",
      "",
      "Revise o codigo abaixo pelos padroes CSDE.",
      "Indique o arquivo ou cole o codigo que deseja revisar:",
      "\$0"
    ],
    "description": "Carrega skill CodeAlign — indique o arquivo ou cole o codigo a revisar"
  },
  "CSDE Revisao Banco": {
    "prefix": "CDU-banco",
    "body": [
      "#fetch:$urlDatabaseAlign",
      "",
      "Revise o SQL abaixo pelos padroes CSDE:",
      "\$0"
    ],
    "description": "Carrega skill DatabaseAlign e abre revisao de SQL/Stored Procedures"
  },
  "CSDE Revisao Branch Code": {
    "prefix": "CDU-code-branch",
    "body": [
      "#fetch:$urlCodeAlign",
      "#changes",
      "",
      "Revise todos os arquivos alterados nessa branch pelos padroes CSDE.",
      "Ignore arquivos que nao sejam .cs, .razor, .cshtml ou .js."
    ],
    "description": "Carrega skill CodeAlign e revisa todos os arquivos de codigo alterados na branch"
  }
}
"@

try {
    Set-Content -Path $snippetsPath -Value $snippetContent -Encoding UTF8
    Write-Host "  [OK] Snippets gravados em:" -ForegroundColor Green
    Write-Host "       $snippetsPath" -ForegroundColor Gray
} catch {
    Write-Host "  [ERRO] Nao foi possivel gravar os snippets." -ForegroundColor Red
    Write-Host "         $_" -ForegroundColor Red
    exit 1
}

# Arquivos .prompt.md para Copilot Chat
$promptCode = @"
---
mode: 'agent'
description: 'Revisa codigo C#/.NET pelos padroes CSDE (CodeAlign)'
---
#fetch:$urlCodeAlign

Responda sempre em portugues.

**Nao analise nenhum codigo automaticamente.**

Aguarde o usuario indicar o que deve ser revisado.
Quando receber a indicacao, pergunte se nao estiver claro.

Exemplos do que o usuario pode informar:
- Colar o codigo diretamente no chat
- Indicar o caminho de um arquivo (ex: Controllers/AlunoController.cs)
- Adicionar o arquivo via anexo no chat

Apos receber o codigo ou arquivo:
1. Identifique o nome do arquivo revisado (sem extensao). Se forem varios, use o nome do principal.
2. Obtenha a data e hora atual no formato YYYY-MM-DD_HH-mm.
3. Aplique os padroes CSDE e gere o relatorio completo em Markdown dentro de um bloco de codigo.
4. Na primeira linha antes do bloco, informe o nome sugerido para salvar o arquivo:
   > **Salve como:** ``revisao-codigo_[nome-do-arquivo]-[YYYY-MM-DD_HH-mm].md``
   Exemplo: ``revisao-codigo_AlunoController-2026-06-25_14-30.md``

O relatorio fica no chat — o usuario copia e salva manualmente com o nome sugerido.

---
Qual arquivo ou codigo voce quer revisar?
"@

$promptBanco = @"
---
mode: 'agent'
description: 'Revisa SQL / Stored Procedures pelos padroes CSDE (DatabaseAlign)'
---
#fetch:$urlDatabaseAlign

Responda sempre em portugues.

**Nao analise nenhum SQL automaticamente.**

Aguarde o usuario colar o SQL ou indicar o arquivo a revisar.

Apos receber o SQL ou arquivo:
1. Identifique o nome da stored procedure ou arquivo revisado (sem extensao).
2. Obtenha a data e hora atual no formato YYYY-MM-DD_HH-mm.
3. Aplique os padroes CSDE e gere o relatorio completo em Markdown dentro de um bloco de codigo.
4. Na primeira linha antes do bloco, informe o nome sugerido para salvar o arquivo:
   > **Salve como:** ``revisao-banco_[nome-da-sp]-[YYYY-MM-DD_HH-mm].md``
   Exemplo: ``revisao-banco_SPL_BuscaAluno-2026-06-25_14-30.md``

O relatorio fica no chat — o usuario copia e salva manualmente com o nome sugerido.

---
Cole o SQL ou informe o arquivo que deseja revisar:
"@

$promptBranch = @"
---
mode: 'agent'
description: 'Revisa todos os arquivos alterados na branch pelos padroes CSDE'
---
#fetch:$urlCodeAlign

Responda sempre em portugues.

**PASSO 1 — Verificar repositorio Git**
Execute no terminal: ``git status 2>&1``
- Se o retorno contiver "fatal: not a git repository" (ou similar), responda:
  > **Erro:** Esta pasta nao e um repositorio Git. Nao e possivel identificar os arquivos alterados. Inicialize o repositorio com ``git init`` ou abra a pasta correta e tente novamente.
  E PARE. Nao execute nenhum passo seguinte.

**PASSO 2 — Capturar nome da branch e data/hora**
Execute: ``git branch --show-current``
Guarde o resultado como [nome-da-branch] (substitua / por - se houver barras).
Obtenha a data e hora atual no formato YYYY-MM-DD_HH-mm. Guarde como [data-hora].

**PASSO 3 — Identificar arquivos alterados**
Execute: ``git diff --name-only HEAD``
- Se nao houver nenhum arquivo listado, informe que nao ha alteracoes na branch e PARE.
- Ignore arquivos que nao sejam .cs, .razor, .cshtml ou .js.

**PASSO 4 — Revisar arquivos**
Para cada arquivo identificado no Passo 3, aplique os padroes CSDE descritos acima.

**PASSO 5 — Entregar o relatorio**
Gere o relatorio completo em Markdown dentro de um bloco de codigo.
Na primeira linha antes do bloco, informe o nome sugerido para salvar:
> **Salve como:** ``revisao-branch_[nome-da-branch]-[data-hora].md``
Exemplo: ``revisao-branch_feature-login-2026-06-25_14-30.md``

O relatorio fica no chat — o usuario copia e salva manualmente com o nome sugerido.
"@

try {
    Set-Content -Path (Join-Path $promptsDir "CDU-code.prompt.md") -Value $promptCode -Encoding UTF8
    Set-Content -Path (Join-Path $promptsDir "CDU-banco.prompt.md") -Value $promptBanco -Encoding UTF8
    Set-Content -Path (Join-Path $promptsDir "CDU-code-branch.prompt.md") -Value $promptBranch -Encoding UTF8
    Write-Host "  [OK] Prompts do Copilot Chat gravados em:" -ForegroundColor Green
    Write-Host "       $promptsDir" -ForegroundColor Gray
} catch {
    Write-Host "  [ERRO] Nao foi possivel gravar os arquivos .prompt.md." -ForegroundColor Red
    Write-Host "         $_" -ForegroundColor Red
    exit 1
}

# Atualizar settings.json com seguranca (compativel com PowerShell 5.1)
try {
    $rawSettings = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw } else { '{}' }
    if ([string]::IsNullOrWhiteSpace($rawSettings)) { $rawSettings = '{}' }

    # Adicionar chaves via regex para evitar dependencia de -AsHashtable (PS 5.1)
    if ($rawSettings -notmatch '"editor\.tabCompletion"') {
        $rawSettings = $rawSettings -replace '^\s*\{', "{`n  `"editor.tabCompletion`": `"on`","
    }

    $rawSettings | Set-Content -Path $settingsPath -Encoding UTF8
    Write-Host "  [OK] settings.json atualizado." -ForegroundColor Green
} catch {
    Write-Host "  [AVISO] Nao foi possivel atualizar settings.json automaticamente." -ForegroundColor Yellow
    Write-Host "          Caminho: $settingsPath" -ForegroundColor Gray
}

# Verificar conectividade com GitHub
Write-Host ""
Write-Host "  Verificando acesso ao GitHub..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri $urlCodeAlign -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop | Out-Null
    Write-Host "  [OK] GitHub acessivel. Skills disponiveis." -ForegroundColor Green
} catch {
    Write-Host "  [AVISO] Nao foi possivel acessar o GitHub agora." -ForegroundColor Yellow
    Write-Host "          Verifique sua conexao antes de usar os prompts." -ForegroundColor Yellow
}

# Resumo final
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalacao concluida!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Proximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Reinicie o VS Code" -ForegroundColor White
Write-Host "  2. Abra o chat do Copilot: Ctrl+Alt+I" -ForegroundColor White
Write-Host "  3. Digite / e escolha o prompt, ou use direto:" -ForegroundColor White
Write-Host ""
Write-Host "     /CDU-code          -> revisao de codigo C#/.NET" -ForegroundColor Cyan
Write-Host "     /CDU-banco         -> revisao de SQL / Stored Procedures" -ForegroundColor Cyan
Write-Host "     /CDU-code-branch   -> revisa todos os arquivos alterados na branch" -ForegroundColor Cyan
Write-Host ""
Write-Host "  IMPORTANTE: use /nome-do-prompt no chat, nao Tab." -ForegroundColor Yellow
Write-Host "  O Tab snippets nao funciona na caixa de chat do Copilot." -ForegroundColor Yellow
Write-Host ""
