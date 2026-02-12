# Script PowerShell para configurar e iniciar Hadoop

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Configurando Hadoop Cluster" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Distribuir configuración
Write-Host "1. Distribuyendo configuración a todos los nodos..." -ForegroundColor Yellow
docker exec hadoop-master bash -c "cp /tmp/hadoop-config/*.xml /opt/hadoop/etc/hadoop/ && cp /tmp/hadoop-config/workers /opt/hadoop/etc/hadoop/ && chown -R hadoop:hadoop /opt/hadoop/etc/hadoop"
docker exec hadoop-worker1 bash -c "cp /tmp/hadoop-config/*.xml /opt/hadoop/etc/hadoop/ && cp /tmp/hadoop-config/workers /opt/hadoop/etc/hadoop/ && chown -R hadoop:hadoop /opt/hadoop/etc/hadoop"
docker exec hadoop-worker2 bash -c "cp /tmp/hadoop-config/*.xml /opt/hadoop/etc/hadoop/ && cp /tmp/hadoop-config/workers /opt/hadoop/etc/hadoop/ && chown -R hadoop:hadoop /opt/hadoop/etc/hadoop"
Write-Host "   Configuración distribuida" -ForegroundColor Green
Write-Host ""

# 2. Limpiar datos antiguos de DataNodes (evita error de clusterID incompatible)
Write-Host "2. Limpiando datos antiguos de DataNodes..." -ForegroundColor Yellow
docker exec hadoop-worker1 bash -c "rm -rf /opt/hadoop/data/dataNode/*"
docker exec hadoop-worker2 bash -c "rm -rf /opt/hadoop/data/dataNode/*"
Write-Host "   Datos de DataNodes limpiados" -ForegroundColor Green
Write-Host ""

# 3. Configurar permisos en directorios de datos de los workers
Write-Host "3. Configurando permisos en directorios de datos..." -ForegroundColor Yellow
docker exec hadoop-worker1 bash -c "chown -R hadoop:hadoop /opt/hadoop/data/dataNode && chmod 755 /opt/hadoop/data/dataNode"
docker exec hadoop-worker2 bash -c "chown -R hadoop:hadoop /opt/hadoop/data/dataNode && chmod 755 /opt/hadoop/data/dataNode"
Write-Host "   Permisos configurados" -ForegroundColor Green
Write-Host ""

# 4. Formatear NameNode
Write-Host "4. Formateando NameNode..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "hdfs namenode -format -force" | Out-Null
Write-Host "   NameNode formateado" -ForegroundColor Green
Write-Host ""

# 5. Iniciar SSH
Write-Host "5. Iniciando SSH en todos los nodos..." -ForegroundColor Yellow
docker exec hadoop-master bash -c "sudo service ssh start" | Out-Null
docker exec hadoop-worker1 bash -c "sudo service ssh start" | Out-Null
docker exec hadoop-worker2 bash -c "sudo service ssh start" | Out-Null
Write-Host "   SSH iniciado" -ForegroundColor Green
Write-Host ""

# 6. Configurar SSH sin contraseña
Write-Host "6. Configurando SSH sin contraseña..." -ForegroundColor Yellow
docker exec hadoop-master bash -c "echo 'StrictHostKeyChecking no' >> /home/hadoop/.ssh/config && chmod 600 /home/hadoop/.ssh/config"
docker exec hadoop-worker1 bash -c "echo 'StrictHostKeyChecking no' >> /home/hadoop/.ssh/config && chmod 600 /home/hadoop/.ssh/config"
docker exec hadoop-worker2 bash -c "echo 'StrictHostKeyChecking no' >> /home/hadoop/.ssh/config && chmod 600 /home/hadoop/.ssh/config"

# Intercambiar claves
docker exec hadoop-master bash -c "cat /home/hadoop/.ssh/id_rsa.pub" | docker exec -i hadoop-worker1 bash -c "cat >> /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-master bash -c "cat /home/hadoop/.ssh/id_rsa.pub" | docker exec -i hadoop-worker2 bash -c "cat >> /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-worker1 bash -c "cat /home/hadoop/.ssh/id_rsa.pub" | docker exec -i hadoop-master bash -c "cat >> /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-worker2 bash -c "cat /home/hadoop/.ssh/id_rsa.pub" | docker exec -i hadoop-master bash -c "cat >> /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-worker1 bash -c "cat /home/hadoop/.ssh/id_rsa.pub" | docker exec -i hadoop-worker2 bash -c "cat >> /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-worker2 bash -c "cat /home/hadoop/.ssh/id_rsa.pub" | docker exec -i hadoop-worker1 bash -c "cat >> /home/hadoop/.ssh/authorized_keys"

docker exec hadoop-master bash -c "chmod 600 /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-worker1 bash -c "chmod 600 /home/hadoop/.ssh/authorized_keys"
docker exec hadoop-worker2 bash -c "chmod 600 /home/hadoop/.ssh/authorized_keys"
Write-Host "   SSH configurado" -ForegroundColor Green
Write-Host ""

# 7. Iniciar HDFS
Write-Host "7. Iniciando HDFS..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "start-dfs.sh"
Start-Sleep -Seconds 10
Write-Host "   HDFS iniciado" -ForegroundColor Green
Write-Host ""

# 8. Crear directorios en HDFS
Write-Host "8. Creando directorios en HDFS..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -mkdir -p /mr-history/tmp && hdfs dfs -mkdir -p /mr-history/done && hdfs dfs -chmod -R 1777 /mr-history && hdfs dfs -mkdir -p /tmp && hdfs dfs -chmod 1777 /tmp"
Write-Host "   Directorios creados" -ForegroundColor Green
Write-Host ""

# 9. Iniciar YARN
Write-Host "9. Iniciando YARN..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "start-yarn.sh" 2>$null
Start-Sleep -Seconds 5
Write-Host "   YARN iniciado" -ForegroundColor Green
Write-Host ""

# 10. Iniciar Job History Server
Write-Host "10. Iniciando Job History Server..." -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "mapred --daemon start historyserver" 2>$null
Start-Sleep -Seconds 3
Write-Host "   Job History Server iniciado" -ForegroundColor Green
Write-Host ""

# 11. Verificar servicios
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Hadoop Cluster Iniciado!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Procesos en hadoop-master:" -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "jps"
Write-Host ""

Write-Host "Procesos en hadoop-worker1:" -ForegroundColor Yellow
docker exec -u hadoop hadoop-worker1 bash -c "jps"
Write-Host ""

Write-Host "Procesos en hadoop-worker2:" -ForegroundColor Yellow
docker exec -u hadoop hadoop-worker2 bash -c "jps"
Write-Host ""

Write-Host "DataNodes registrados en HDFS:" -ForegroundColor Yellow
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Name:'"
Write-Host ""

Write-Host "Interfaces Web disponibles:" -ForegroundColor Yellow
Write-Host "  - NameNode UI:        http://localhost:9870" -ForegroundColor White
Write-Host "  - ResourceManager UI: http://localhost:8088" -ForegroundColor White
Write-Host "  - Job History Server: http://localhost:19888" -ForegroundColor White
Write-Host "  - DataNode 1 UI:      http://localhost:9864" -ForegroundColor White
Write-Host "  - DataNode 2 UI:      http://localhost:9865" -ForegroundColor White
Write-Host ""

Write-Host "Comandos útiles:" -ForegroundColor Yellow
Write-Host "  - Ver reporte HDFS:   docker exec -u hadoop hadoop-master hdfs dfsadmin -report" -ForegroundColor White
Write-Host "  - Ver nodos YARN:     docker exec -u hadoop hadoop-master yarn node -list" -ForegroundColor White
Write-Host "  - Acceder al master:  docker exec -it hadoop-master bash" -ForegroundColor White
