#Requires -Version 5.1
<#
.SYNOPSIS
  Remove a credencial NVIDIA malformada do OpenCode.

.DESCRIPTION
  A /connect esconde fornecedores que ja temem credencial activa. A entrada da
  NVIDIA existe mas tem um URL do GitHub no campo da chave, portanto nunca
  funcionou - e aNVIDIA nao aparece para reconectar.

  Este script apaga essa entrada (que nao tem nada de util) e deixa o fornecedor
  disponivel na /connect.

  FECHE O OPENCODE ANTES DE CORRER ISTO.
#>

$ErrorActionPreference = 'Stop'

# --- Aviso: o OpenCode nao pode estar aberto ---
$running = Get-Process -Name 'opencode' -ErrorAction SilentlyContinue
if ($running) {
    Write-Host ''
    Write-Host '  FECHA O OPENCODE PRIMEIRO.' -ForegroundColor Red
    Write-Host '  Processo a correr: opencode (PID ' + $running.Id + ')' -ForegroundColor DarkYellow
    Write-Host ''
    Write-Host '  A base de dados esta aberta. Escrever nela com o OpenCode vivo pode' -ForegroundColor DarkYellow
    Write-Host '  corromper o ficheiro ou as alteracoes podem ser perdidas.' -ForegroundColor DarkYellow
    Write-Host ''
    pause
}

$dbPath = Join-Path $env:USERPROFILE '.local\share\opencode\opencode.db'
if (-not (Test-Path $dbPath)) { throw "Base de dados nao encontrada: $dbPath" }

# --- Mostra o estado actual, sem revelar segredos ---
$helper = Join-Path $env:TEMP 'opencode\inspect-nvidia.js'
@'
const { DatabaseSync } = require("node:sqlite");
const db = new DatabaseSync(process.argv[2], { readOnly: true });
const rows = db.prepare("SELECT id, label, value, active FROM credential WHERE integration_id = 'nvidia'").all();
if (!rows.length) { console.log("NENHUMA"); process.exit(0); }
for (const r of rows) {
  let v = {};
  try { v = JSON.parse(r.value); } catch {}
  const k = v.key || "";
  // Never print more than a prefix of the stored value
  console.log("id=" + r.id + " | label=" + r.label + " | active=" + r.active +
              " | tipo=" + (v.type || "?") +
              " | valor=" + (k.length > 24 ? k.slice(0, 24) + "..." : k));
}
'@ | Set-Content -Path $helper -Encoding UTF8

Write-Host ''
Write-Host '  Estado actual da credencial NVIDIA:' -ForegroundColor Cyan
node $helper $dbPath | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$dbPath.bak-$stamp"
Copy-Item $dbPath $backup
Write-Host ''
Write-Host "  Backup: $backup" -ForegroundColor Green

# --- Apaga ---
@'
const { DatabaseSync } = require("node:sqlite");
const db = new DatabaseSync(process.argv[2]);
const info = db.prepare("DELETE FROM credential WHERE integration_id = 'nvidia'").run();
console.log("APAGADOS=" + info.changes);
db.close();
'@ | Set-Content -Path $helper -Encoding UTF8

$result = node $helper $dbPath 2>&1
Write-Host "  $result" -ForegroundColor Green
Remove-Item $helper -ErrorAction SilentlyContinue

Write-Host ''
Write-Host '  Feito. Agora:' -ForegroundColor Cyan
Write-Host '    1. Arranca o OpenCode' -ForegroundColor White
Write-Host '    2. /connect  ->  a NVIDIA volta a aparecer' -ForegroundColor White
Write-Host '    3. Escolhe NVIDIA e cola a chave nvapi-...' -ForegroundColor White
Write-Host ''
Write-Host '  Para desfazer, apaga os .bak mais recentes em:' -ForegroundColor DarkGray
Write-Host "    $dbPath" -ForegroundColor DarkGray
Write-Host ''
