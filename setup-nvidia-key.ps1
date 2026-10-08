#Requires -Version 5.1
<#
.SYNOPSIS
  Aplica uma chave da API da NVIDIA ao OpenCode.

.DESCRIPTION
  Pede a chave com entrada mascarada (nada aparece no ecrã), valida o formato,
  faz backup da base de dados, grava a credencial e TESTA a chave contra a API
  da NVIDIA antes de dar o trabalho por feito.

  A chave nunca é passada como argumento de linha de comandos (ficaria visível
  na lista de processos) nem escrita em ficheiros para além da base de dados
  de credenciais do OpenCode.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\setup-nvidia-key.ps1
#>

$ErrorActionPreference = 'Stop'

$dbPath = Join-Path $env:USERPROFILE '.local\share\opencode\opencode.db'
$nodeHelper = Join-Path $env:TEMP 'opencode\nvidia-cred.js'

if (-not (Test-Path $dbPath)) {
    throw "Base de dados do OpenCode nao encontrada em $dbPath. Abre o OpenCode uma vez e volta a tentar."
}

Write-Host ''
Write-Host '  NVIDIA API key para o OpenCode' -ForegroundColor Cyan
Write-Host '  --------------------------------' -ForegroundColor DarkGray
Write-Host ''
Write-Host '  1. Vai a https://build.nvidia.com  -> conta -> API Keys'
Write-Host '  2. Gera uma chave (comeca por nvapi-)'
Write-Host '  3. Cola aqui abaixo. A entrada fica mascarada.'
Write-Host ''

# Entrada mascarada: nao ecoa, nao fica no historico da PowerShell
$secure = Read-Host '  Cole a chave (nvapi-...)' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

$key = $key.Trim()

if ([string]::IsNullOrWhiteSpace($key)) {
    throw 'Nenhuma chave introduzida.'
}

# Validacao do formato antes de tocar em seja o que for
if (-not $key.StartsWith('nvapi-')) {
    throw ("A chave nao comeca por 'nvapi-'. Recebemos: " + $key.Substring(0, [Math]::Min(12, $key.Length)) + '...  ' +
           'Chaves do build.nvidia.com comecam sempre por nvapi-.')
}
if ($key.Length -lt 40) {
    throw 'A chave e demasiado curta para ser uma chave da NVIDIA. Copia a inteira.'
}
if ($key -match 'github\.com') {
    throw 'Isto e um URL do GitHub, nao uma chave da NVIDIA. Foi o que estava gravado antes - por isso nunca funcionou.'
}

Write-Host ''
Write-Host '  [1/4] Formato valido.' -ForegroundColor Green

# Backup antes de escrever
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$dbPath.bak-$stamp"
Copy-Item $dbPath $backup
Write-Host "  [2/4] Backup: $backup" -ForegroundColor Green

# Passa a chave por variavel de ambiente, nunca na linha de comandos
$env:OPENCODE_NVIDIA_KEY = $key

@'
const { DatabaseSync } = require("node:sqlite");
const path = process.argv[2];
const key = process.env.OPENCODE_NVIDIA_KEY;
const db = new DatabaseSync(path);

const rows = db.prepare("SELECT id, integration_id, value, active FROM credential WHERE integration_id = 'nvidia'").all();

if (rows.length === 0) {
  // Sem registo: cria um
  const id = "cred_" + require("node:crypto").randomBytes(16).toString("hex");
  db.prepare(`INSERT INTO credential (id, integration_id, label, value, connector_id, method_id, active, time_created, time_updated)
              VALUES (?, 'nvidia', 'Nvidia', ?, NULL, NULL, 1, ?, ?)`)
    .run(id, JSON.stringify({ type: "key", key }), Date.now(), Date.now());
  console.log("INSERTED");
} else {
  for (const r of rows) {
    let parsed;
    try { parsed = JSON.parse(r.value); } catch { parsed = { type: "key" }; }
    parsed.type = "key";
    parsed.key = key;
    db.prepare("UPDATE credential SET value = ?, active = 1, time_updated = ? WHERE id = ?")
      .run(JSON.stringify(parsed), Date.now(), r.id);
    console.log("UPDATED " + r.id);
  }
}
db.close();
'@ | Set-Content -Path $nodeHelper -Encoding UTF8

try {
    $result = node $nodeHelper $dbPath 2>&1
    Write-Host "  [3/4] Credencial gravada ($result)" -ForegroundColor Green

    # Testa a chave contra a API real antes de dizer que funcionou
    Write-Host '  [4/4] A testar a chave...' -ForegroundColor Gray
    try {
        $resp = Invoke-RestMethod -Uri 'https://integrate.api.nvidia.com/v1/models' `
                                  -Headers @{ Authorization = "Bearer $key" } `
                                  -TimeoutSec 30
        $count = ($resp.data | Measure-Object).Count
        Write-Host ''
        Write-Host "  Chave valida. $count modelos disponiveis." -ForegroundColor Green
        Write-Host '  Para usar: /models  e escolhe um que comece por nvidia/' -ForegroundColor Cyan
    } catch {
        Write-Host ''
        Write-Host '  A chave foi gravada mas a API rejeitou-a:' -ForegroundColor Yellow
        Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkYellow
        Write-Host '  Verifica se a conta esta activa em build.nvidia.com.' -ForegroundColor DarkYellow
    }
} finally {
    # Limpa a chave da memoria do processo
    Remove-Item Env:\OPENCODE_NVIDIA_KEY -ErrorAction SilentlyContinue
    Remove-Item $nodeHelper -ErrorAction SilentlyContinue
    $key = $null
    $secure = $null
}

Write-Host ''
Write-Host '  Reinicia o OpenCode para a alteracao entrar em vigor.' -ForegroundColor Cyan
Write-Host ''
