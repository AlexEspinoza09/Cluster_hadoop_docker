try {
    Write-Host "Probando acceso a las interfaces web..." -ForegroundColor Cyan
    Write-Host ""

    # Probar ResourceManager
    Write-Host "Probando ResourceManager (http://localhost:8088)..." -ForegroundColor Yellow
    $rm = Invoke-WebRequest -Uri "http://localhost:8088" -UseBasicParsing -TimeoutSec 10
    Write-Host "  Status: $($rm.StatusCode)" -ForegroundColor Green
    Write-Host "  Content Length: $($rm.Content.Length) bytes" -ForegroundColor Green
    Write-Host ""

    # Probar NameNode
    Write-Host "Probando NameNode (http://localhost:9870)..." -ForegroundColor Yellow
    $nn = Invoke-WebRequest -Uri "http://localhost:9870" -UseBasicParsing -TimeoutSec 10
    Write-Host "  Status: $($nn.StatusCode)" -ForegroundColor Green
    Write-Host "  Content Length: $($nn.Content.Length) bytes" -ForegroundColor Green
    Write-Host ""

    # Probar Job History Server
    Write-Host "Probando Job History Server (http://localhost:19888)..." -ForegroundColor Yellow
    $jhs = Invoke-WebRequest -Uri "http://localhost:19888" -UseBasicParsing -TimeoutSec 10
    Write-Host "  Status: $($jhs.StatusCode)" -ForegroundColor Green
    Write-Host "  Content Length: $($jhs.Content.Length) bytes" -ForegroundColor Green
    Write-Host ""

    Write-Host "Todas las interfaces web están funcionando correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Abre tu navegador en:" -ForegroundColor Cyan
    Write-Host "  - ResourceManager: http://localhost:8088" -ForegroundColor White
    Write-Host "  - NameNode:        http://localhost:9870" -ForegroundColor White
    Write-Host "  - Job History:     http://localhost:19888" -ForegroundColor White

} catch {
    Write-Host "Error al conectar: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica que los servicios estén corriendo:" -ForegroundColor Yellow
    Write-Host "  docker exec -u hadoop hadoop-master jps"
}
