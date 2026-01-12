# Script de Monitoreo en Tiempo Real del Cluster Hadoop

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "MONITOR DE CLUSTER HADOOP" -ForegroundColor Cyan
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

while ($true) {
    Clear-Host

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "Actualizado: $timestamp" -ForegroundColor Green
    Write-Host ""

    # Nodos YARN
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "NODOS YARN ACTIVOS" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    docker exec -u hadoop hadoop-master yarn node -list 2>$null
    Write-Host ""

    # Aplicaciones corriendo
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "APLICACIONES EN EJECUCIÓN" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    $apps = docker exec -u hadoop hadoop-master yarn application -list -appStates RUNNING 2>$null
    if ($apps -match "Total number of applications") {
        Write-Host $apps
    } else {
        Write-Host "No hay aplicaciones ejecutándose actualmente" -ForegroundColor Yellow
    }
    Write-Host ""

    # Estado HDFS
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "ESTADO DE HDFS" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    docker exec -u hadoop hadoop-master hdfs dfsadmin -report 2>$null | Select-String -Pattern "Configured Capacity|DFS Used|DFS Remaining|Live datanodes"
    Write-Host ""

    # Procesos en master
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "PROCESOS EN HADOOP-MASTER" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    docker exec -u hadoop hadoop-master jps 2>$null
    Write-Host ""

    Write-Host "Próxima actualización en 5 segundos..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
}
