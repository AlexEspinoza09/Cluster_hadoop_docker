# Script para reiniciar completamente Hadoop

Write-Host "Deteniendo servicios de Hadoop..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "stop-yarn.sh" 2>$null
docker exec -u hadoop hadoop-master bash -c "stop-dfs.sh" 2>$null
docker exec -u hadoop hadoop-master bash -c "mapred --daemon stop historyserver" 2>$null

Start-Sleep -Seconds 5

Write-Host "Iniciando servicios de Hadoop..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "start-dfs.sh"
Start-Sleep -Seconds 10

docker exec -u hadoop hadoop-master bash -c "start-yarn.sh"
Start-Sleep -Seconds 5

docker exec -u hadoop hadoop-master bash -c "mapred --daemon start historyserver"
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Estado del cluster:" -ForegroundColor Cyan
docker exec -u hadoop hadoop-master jps

Write-Host ""
Write-Host "Nodos YARN:" -ForegroundColor Cyan
docker exec -u hadoop hadoop-master yarn node -list 2>$null
