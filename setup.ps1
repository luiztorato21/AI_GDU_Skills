# ================================================================
#  setup.ps1 — AI GDU Skills CSDE
#  Configura os snippets do VS Code para usar as skills do GitHub
#
#  Como executar:
#    1. Abra o PowerShell
#    2. Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#    3. .\setup.ps1
# ================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalando Skills CSDE no VS Code   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── URLs das skills no GitHub ─────────────────────────────────────────────

$urlCodeAlign = "https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/code/CodeAlign.md"
$urlDatabaseAlign = "https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/database/DatabaseAlign.md"

# ── Localizar pasta de snippets do VS Code ────────────────────────────────

$snippetsDir  = "$env:APPDATA\Code\User\snippets"
$snippetsPath = "$snippetsDir\csde.code-snippets"

if (-not (Test-Path $snippetsDir)) {
    New-Item -ItemType Directory -Path $snippetsDir -Force | Out-Null
}

# ── Conteúdo dos snippets ─────────────────────────────────────────────────

$snippetContent = @"
{
  "CSDE Revisao Code": {
    "prefix": "CDU-code",
    "body": [
      "#fetch:$urlCodeAlign",
      "",
      "Revise o código abaixo pelos padrões CSDE:",
      "\$0"
    ],
    "description": "Carrega skill CodeAlign e abre revisão de código C#/.NET"
  },
  "CSDE Revisao Banco": {
    "prefix": "CDU-banco",
    "body": [
      "#fetch:$urlDatabaseAlign",
      "",
      "Revise o SQL abaixo pelos padrões CSDE:",
      "\$0"
    ],
    "description": "Carrega skill DatabaseAlign e abre revisão de SQL/Stored Procedures"
  },
  "CSDE Revisao Branch Code": {
    "prefix": "CDU-code-branch",
    "body": [
      "#fetch:$urlCodeAlign",
      "#changes",
      "",
      "Revise todos os arquivos alterados nessa branch pelos padrões CSDE.",
      "Ignore arquivos que não sejam .cs, .razor, .cshtml ou .js."
    ],
    "description": "Carrega skill CodeAlign + revisa todos os arquivos de código alterados na branch"
  }
}
"@

# ── Gravar snippets ───────────────────────────────────────────────────────

try {
    Set-Content -Path $snippetsPath -Value $snippetContent -Encoding UTF8
    Write-Host "  [OK] Snippets gravados em:" -ForegroundColor Green
    Write-Host "       $snippetsPath" -ForegroundColor Gray
} catch {
    Write-Host "  [ERRO] Nao foi possivel gravar os snippets." -ForegroundColor Red
    Write-Host "         $_" -ForegroundColor Red
    exit 1
}

# ── Habilitar Tab Completion nas settings ─────────────────────────────────

$settingsPath = "$env:APPDATA\Code\User\settings.json"

if (Test-Path $settingsPath) {
    $rawSettings = Get-Content $settingsPath -Raw

    if ($rawSettings -notmatch "editor.tabCompletion") {
        # Insere a config antes do último }
        $rawSettings = $rawSettings.TrimEnd()
        if ($rawSettings.EndsWith("}")) {
            $rawSettings = $rawSettings.Substring(0, $rawSettings.Length - 1)
            # Adiciona vírgula se o arquivo não estiver vazio além do {}
            if ($rawSettings.Trim() -ne "{") {
                $rawSettings = $rawSettings.TrimEnd().TrimEnd(',') + ','
            }
            $rawSettings += "`n  `"editor.tabCompletion`": `"on`"`n}"
        }
        Set-Content $settingsPath -Value $rawSettings -Encoding UTF8
        Write-Host "  [OK] editor.tabCompletion habilitado no settings.json" -ForegroundColor Green
    } else {
        Write-Host "  [OK] editor.tabCompletion ja configurado." -ForegroundColor Gray
    }
} else {
    # Cria settings.json do zero
    $minSettings = "{`n  `"editor.tabCompletion`": `"on`"`n}"
    Set-Content $settingsPath -Value $minSettings -Encoding UTF8
    Write-Host "  [OK] settings.json criado com tabCompletion habilitado." -ForegroundColor Green
}

# ── Verificar conectividade com GitHub ───────────────────────────────────

Write-Host ""
Write-Host "  Verificando acesso ao GitHub..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri $urlCodeAlign -Method Head -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] GitHub acessivel. Skills disponiveis." -ForegroundColor Green
} catch {
    Write-Host "  [AVISO] Nao foi possivel acessar o GitHub agora." -ForegroundColor Yellow
    Write-Host "          Verifique sua conexao antes de usar os snippets." -ForegroundColor Yellow
}

# ── Resumo final ──────────────────────────────────────────────────────────

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Instalacao concluida!                " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Proximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Reinicie o VS Code" -ForegroundColor White
Write-Host "  2. Abra o chat (Ctrl+Alt+I no Copilot)" -ForegroundColor White
Write-Host "  3. Digite um dos atalhos abaixo e aperte Tab:" -ForegroundColor White
Write-Host ""
Write-Host "     CDU-code     → revisao de codigo C#/.NET" -ForegroundColor Cyan
Write-Host "     CDU-banco    → revisao de SQL / Stored Procedures" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Atalhos disponiveis:" -ForegroundColor Yellow
Write-Host ""
Write-Host "     CDU-code          -> revisao de codigo C#/.NET (cola o codigo)" -ForegroundColor Cyan
Write-Host "     CDU-banco         -> revisao de SQL / Stored Procedures" -ForegroundColor Cyan
Write-Host "     CDU-code-branch   -> revisao de TODOS os arquivos alterados na branch" -ForegroundColor Cyan
Write-Host ""
