@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ========================================
echo   IMPORT LOLANA - copiar para Supabase
echo ========================================
echo.
echo Escolha (e Enter):
echo   1 = CLIENTES   (import — correr primeiro)
echo   2 = PEDIDOS    (import — depois dos clientes)
echo   3 = SERVICOS   (import — depois de clientes; pode ser antes de pedidos)
echo   4 = COMPLETO   (restaurar-dados-completo.sql — tudo num so Run)
echo   5 = DASHBOARD  (consulta SQL: totais + lista pedidos — so ver na base)
echo   6 = CORRIGIR   (se der erro: column pedidos.created_at does not exist)
echo.
set /p op="Digite 1, 2, 3, 4, 5 ou 6: "

if "%op%"=="1" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copiar-sql-para-supabase.ps1" clientes
if "%op%"=="2" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copiar-sql-para-supabase.ps1" pedidos
if "%op%"=="3" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copiar-sql-para-supabase.ps1" servicos
if "%op%"=="4" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copiar-sql-para-supabase.ps1" completo
if "%op%"=="5" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copiar-sql-para-supabase.ps1" dashboard
if "%op%"=="6" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copiar-sql-para-supabase.ps1" corrigir

if not "%op%"=="1" if not "%op%"=="2" if not "%op%"=="3" if not "%op%"=="4" if not "%op%"=="5" if not "%op%"=="6" echo Opcao invalida.
echo.
pause
