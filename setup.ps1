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
      "Revise o codigo abaixo pelos padroes CSDE:",
      "\$0"
    ],
    "description": "Carrega skill CodeAlign e abre revisao de codigo C#/.NET"
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
Revise o codigo abaixo pelos padroes CSDE.
Ao finalizar, salve o relatorio em um arquivo chamado ``revisao-codigo.md`` na raiz do workspace:

"@

$promptBanco = @"
---
mode: 'agent'
description: 'Revisa SQL / Stored Procedures pelos padroes CSDE (DatabaseAlign)'
---
#fetch:$urlDatabaseAlign

Responda sempre em portugues.
Revise o SQL abaixo pelos padroes CSDE.
Ao finalizar, salve o relatorio em um arquivo chamado ``revisao-banco.md`` na raiz do workspace:

"@

$promptBranch = @"
---
mode: 'agent'
description: 'Revisa todos os arquivos alterados na branch pelos padroes CSDE'
---
#fetch:$urlCodeAlign
#changes

Responda sempre em portugues.
Revise todos os arquivos alterados nessa branch pelos padroes CSDE.
Ignore arquivos que nao sejam .cs, .razor, .cshtml ou .js.
Ao finalizar a revisao, salve o relatorio completo em um arquivo chamado ``revisao-branch.md`` na raiz do workspace.
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

# Atualizar settings.json com seguranca
try {
    if (Test-Path $settingsPath) {
        $rawSettings = Get-Content $settingsPath -Raw
        if ([string]::IsNullOrWhiteSpace($rawSettings)) {
            $settings = [ordered]@{}
        } else {
            $settings = $rawSettings | ConvertFrom-Json -AsHashtable
        }
    } else {
        $settings = [ordered]@{}
    }

    $settings["editor.tabCompletion"] = "on"
    $settings["chat.promptFilesLocations"] = @($promptsDir.Replace("\", "/"))

    $settingsJson = $settings | ConvertTo-Json -Depth 10
    Set-Content -Path $settingsPath -Value $settingsJson -Encoding UTF8

    Write-Host "  [OK] settings.json atualizado." -ForegroundColor Green
} catch {
    Write-Host "  [AVISO] Nao foi possivel atualizar settings.json automaticamente." -ForegroundColor Yellow
    Write-Host "          Verifique se o arquivo esta com JSON valido." -ForegroundColor Yellow
    Write-Host "          Caminho: $settingsPath" -ForegroundColor Gray
}

# Verificar conectividade com GitHub
Write-Host ""
Write-Host "  Verificando acesso ao GitHub..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri $urlCodeAlign -Method Head -TimeoutSec 5 -ErrorAction Stop | Out-Null
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
