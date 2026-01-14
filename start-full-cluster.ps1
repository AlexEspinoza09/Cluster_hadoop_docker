# Script completo para levantar el cluster desde cero

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "INICIANDO CLUSTER HADOOP COMPLETO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Levantar contenedores Docker
Write-Host "1. Levantando contenedores Docker..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "   Esperando que los contenedores estén listos..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# 2. Configurar e iniciar Hadoop
Write-Host ""
Write-Host "2. Configurando e iniciando Hadoop..." -ForegroundColor Yellow
& ".\scripts\configure-and-start-hadoop.ps1"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "CLUSTER COMPLETAMENTE INICIADO" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Accede a las interfaces web:" -ForegroundColor Cyan
Write-Host "  - ResourceManager: http://localhost:8088" -ForegroundColor White
Write-Host "  - NameNode:        http://localhost:9870" -ForegroundColor White
Write-Host "  - Job History:     http://localhost:19888" -ForegroundColor White
