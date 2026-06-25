# AI GDU Skills — Guia de Configuração
## Configure uma vez. Use para sempre.

> Após rodar o `setup.ps1`, você digita `CDU-code` ou `CDU-banco` no chat
> do VS Code e aperta **Tab**. O atalho carrega a skill direto do GitHub
> automaticamente — sem lembrar URL, sem clonar nada.

---

## O que são as Skills

São dois arquivos no GitHub que ensinam a IA a revisar código seguindo os
padrões da coordenadoria CSDE:

| Skill | Arquivo no GitHub | Para que serve |
|---|---|---|
| **CodeAlign** | `skills/code/CodeAlign.md` | Revisar código C# / .NET / JS / Blazor |
| **DatabaseAlign** | `skills/database/DatabaseAlign.md` | Revisar SQL / Stored Procedures |

Repositório: https://github.com/luiztorato21/AI_GDU_Skills

---

## Pré-requisitos

Antes de começar, confirme que você tem instalado:

- [ ] **VS Code** — https://code.visualstudio.com
- [ ] **GitHub Copilot** ou **Claude for VS Code** (extensão no VS Code)
- [ ] **PowerShell** (já vem no Windows — não precisa instalar)

---

## Instalação — Opção A: Script automático ✅ Recomendado

> Faz tudo em 30 segundos. Funciona em qualquer máquina Windows.

### Passo 1 — Baixar o script

Salve o arquivo `setup.ps1` (está neste repositório) em qualquer pasta.
Exemplo: `C:\Users\SeuNome\Downloads\setup.ps1`

### Passo 2 — Abrir o PowerShell

Pressione `Windows + X` → clique em **Terminal** ou **PowerShell**

### Passo 3 — Permitir execução de scripts (só na primeira vez)

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```
Quando perguntar, digite `S` e pressione Enter.

### Passo 4 — Executar o setup

Navegue até a pasta onde salvou o arquivo:
```powershell
cd C:\Users\SeuNome\Downloads
.\setup.ps1
```

Você vai ver no terminal:
```
========================================
   Instalando Skills CSDE no VS Code
========================================

  [OK] Snippets gravados em: C:\Users\...\snippets\csde.code-snippets
  [OK] editor.tabCompletion habilitado

========================================
   Instalacao concluida!
========================================

  1. Reinicie o VS Code
  2. Abra o chat (Ctrl+Alt+I)
  3. Digite um dos atalhos e aperte Tab:

     CDU-code         → revisao de codigo C#/.NET
     CDU-banco        → revisao de SQL / Stored Procedures
     CDU-code-branch  → revisao de TODOS os arquivos alterados na branch
```

### Passo 5 — Reiniciar o VS Code

Feche e abra o VS Code novamente para carregar os snippets.

---

## Instalação — Opção B: Manual (sem rodar script)

Se preferir fazer na mão, siga os passos abaixo.

### Passo 1 — Abrir o arquivo de snippets

No VS Code:
```
Ctrl+Shift+P
→ digite: Snippets: Configure User Snippets
→ selecione: New Global Snippets file...
→ nome: csde
→ Enter
```

### Passo 2 — Colar o conteúdo

Apague tudo que estiver no arquivo e cole exatamente isso:

```json
{
  "CSDE Revisao Code": {
    "prefix": "CDU-code",
    "body": [
      "#fetch:https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/code/CodeAlign.md",
      "",
      "Revise o código abaixo pelos padrões CSDE:",
      "$0"
    ],
    "description": "Carrega skill CodeAlign e abre revisão de código"
  },
  "CSDE Revisao Banco": {
    "prefix": "CDU-banco",
    "body": [
      "#fetch:https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/database/DatabaseAlign.md",
      "",
      "Revise o SQL abaixo pelos padrões CSDE:",
      "$0"
    ],
    "description": "Carrega skill DatabaseAlign e abre revisão de banco"
  },
  "CSDE Revisao Branch Code": {
    "prefix": "CDU-code-branch",
    "body": [
      "#fetch:https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/code/CodeAlign.md",
      "#changes",
      "",
      "Revise todos os arquivos alterados nessa branch pelos padrões CSDE.",
      "Ignore arquivos que não sejam .cs, .razor, .cshtml ou .js."
    ],
    "description": "Carrega skill CodeAlign + revisa todos os arquivos de código alterados na branch"
  }
}
```

### Passo 3 — Salvar e habilitar Tab Completion

Salve com `Ctrl+S`.

Depois abra as configurações:
```
Ctrl+Shift+P
→ Preferences: Open User Settings (JSON)
```

Adicione essa linha dentro das chaves `{ }`:
```json
"editor.tabCompletion": "on"
```

### Passo 4 — Reiniciar o VS Code

---

## Como usar no dia a dia

### Usar digitando código direto no chat

```
1. Abra o chat
   → Copilot: Ctrl+Alt+I
   → Claude:  clique no painel lateral

2. Digite:  CDU-code  →  Tab

3. O chat abre com a skill já carregada:
   #fetch:https://raw.githubusercontent.com/.../CodeAlign.md

   Revise o código abaixo pelos padrões CSDE:
   |cursor aqui|

4. Cole o código e pressione Enter
```

### Usar apontando para um arquivo do projeto

```
1. Abra o chat
2. Digite:  CDU-code  →  Tab
3. Substitua o caminho pelo arquivo real:
   Controllers/AprovacaoMonitorController.cs
4. Enter
```

### Usar para revisar SQL / Stored Procedure

```
1. Abra o chat
2. Digite:  CDU-banco  →  Tab
3. Cole a stored procedure
4. Enter
```

### ⭐ Revisar tudo que mudou na branch — código

> Não precisa selecionar nenhum arquivo.
> O `#changes` detecta automaticamente todos os arquivos
> alterados na branch atual em relação à main/master.

```
1. Abra o chat
2. Digite:  CDU-code-branch  →  Tab
3. Enter — a IA já sabe quais arquivos revisar
```

O chat abre assim:
```
#fetch:https://raw.githubusercontent.com/.../CodeAlign.md
#changes

Revise todos os arquivos alterados nessa branch pelos padrões CSDE.
Ignore arquivos que não sejam .cs, .razor, .cshtml ou .js.
```

### ⭐ Revisar tudo que mudou na branch — SQL

```
1. Abra o chat
2. Digite:  CDU-code-branch  →  Tab
3. Enter — revisa todos os .sql alterados na branch
```

---

## Resultado esperado

A IA vai responder com o relatório já formatado:

```markdown
# Relatório de Revisão de Código — CSDE
**Data:** 25/06/2026
**Arquivos revisados:** AprovacaoMonitorController.cs

---

## Resumo

| Severidade  | Quantidade |
|-------------|------------|
| 🔴 GRAVE    | 1          |
| 🟡 MODERADO | 2          |
| 🟢 LEVE     | 0          |
| **Total**   | **3**      |

**Veredicto:** ❌ Reprovado

---

## Apontamentos

### `AprovacaoMonitorController.cs`

#### 🔴 GRAVE — [C-02] CSRF ausente
- **Linha:** 47
- **Problema:** método POST sem [ValidateAntiForgeryToken]
- **Correção:** adicionar o atributo antes do [HttpPost]
```

---

## Referência rápida dos atalhos

| Digite no chat | + Tab | O que faz |
|---|---|---|
| `CDU-code` | Tab | Revisão de código C# / .NET / JS / Blazor — cola o código no chat |
| `CDU-banco` | Tab | Revisão de SQL / Stored Procedures — cola o SQL no chat |
| `CDU-code-branch` | Tab | Revisão de **todos os arquivos alterados na branch atual** |

---

## Solução de problemas

**Tab não expande o snippet**
→ Confirme que `editor.tabCompletion` está como `"on"` nas configurações
→ Reinicie o VS Code após a configuração

**`#fetch` não funciona / skill não carrega**
→ Confirme que está usando o Copilot Chat ou Claude for VS Code
→ Verifique conexão com internet (o VS Code precisa acessar o GitHub)
→ Tente colar a URL diretamente: `https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/code/CodeAlign.md`

**Script bloqueado pelo Windows**
→ Rode o Passo 3 da instalação para liberar a execução de scripts
→ `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

---

## URLs de referência

```
CodeAlign (raw):
https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/code/CodeAlign.md

DatabaseAlign (raw):
https://raw.githubusercontent.com/luiztorato21/AI_GDU_Skills/refs/heads/main/skills/database/DatabaseAlign.md
```
