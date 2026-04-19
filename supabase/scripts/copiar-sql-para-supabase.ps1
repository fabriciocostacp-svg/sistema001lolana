# Copia o SQL escolhido para a area de transferencia (Ctrl+V no Supabase SQL Editor).
# Uso:
#   .\copiar-sql-para-supabase.ps1 clientes
#   .\copiar-sql-para-supabase.ps1 pedidos
#   .\copiar-sql-para-supabase.ps1 servicos
#   .\copiar-sql-para-supabase.ps1 completo
#   .\copiar-sql-para-supabase.ps1 dashboard
#   .\copiar-sql-para-supabase.ps1 corrigir   (created_at/updated_at em pedidos)

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('clientes', 'pedidos', 'servicos', 'completo', 'dashboard', 'corrigir')]
    [string] $Qual
)

$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$arquivos = @{
    clientes  = 'import-clientes-backup.sql'
    pedidos   = 'import-pedidos-backup.sql'
    servicos  = 'import-servicos-backup.sql'
    completo  = 'restaurar-dados-completo.sql'
    dashboard = 'consulta-dashboard-resumo.sql'
    corrigir  = 'corrigir-pedidos-created-at.sql'
}
$nome = $arquivos[$Qual]
$caminho = Join-Path $dir $nome

if (-not (Test-Path $caminho)) {
    Write-Error "Ficheiro nao encontrado: $caminho"
}

Get-Content -LiteralPath $caminho -Raw -Encoding UTF8 | Set-Clipboard
$tamanho = (Get-Item -LiteralPath $caminho).Length
Write-Host ""
Write-Host "OK: $nome copiado ($tamanho bytes)." -ForegroundColor Green
Write-Host ""
Write-Host "Agora:" -ForegroundColor Cyan
Write-Host "  1. Supabase (site) > SQL Editor > + New query (ou separador vazio)"
Write-Host "  2. Clica dentro da caixa branca"
Write-Host "  3. Ctrl+V"
Write-Host "  4. Run (ou Ctrl+Enter)"
Write-Host ""

if ($Qual -eq 'completo') {
    Write-Host "Ficheiro grande: o primeiro Ctrl+V pode demorar 1-2 segundos." -ForegroundColor Yellow
    Write-Host "Importa clientes + servicos + pedidos na ordem certa." -ForegroundColor Yellow
}
elseif ($Qual -eq 'dashboard') {
    Write-Host "Isto so CONSULTA a base (nao altera dados)." -ForegroundColor Yellow
    Write-Host "Se os numeros batem com o esperado mas a app mostra 0, confira .env e deploy secure-api." -ForegroundColor Yellow
}
elseif ($Qual -eq 'corrigir') {
    Write-Host "Corre no Supabase ANTES de voltar a abrir a app (colunas created_at/updated_at em pedidos)." -ForegroundColor Yellow
}
else {
    Write-Host "Ordem recomendada para import: clientes -> pedidos -> servicos" -ForegroundColor Yellow
}
Write-Host ""
