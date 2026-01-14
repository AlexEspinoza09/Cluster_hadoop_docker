# Comandos para Probar el Cluster Hadoop

Este documento contiene todos los comandos que puedes ejecutar tú mismo para verificar y probar el trabajo del cluster.

## 1. Verificar Estado del Cluster

### Ver procesos de Hadoop corriendo
```powershell
docker exec -u hadoop hadoop-master jps
```
**Deberías ver**: NameNode, DataNode, ResourceManager, NodeManager, JobHistoryServer

### Ver nodos YARN activos
```powershell
docker exec -u hadoop hadoop-master yarn node -list
```
**Deberías ver**: 3 nodos en estado RUNNING

### Ver estado de HDFS
```powershell
docker exec -u hadoop hadoop-master hdfs dfsadmin -report
```
**Muestra**: Capacidad total, espacio usado, nodos vivos/muertos

### Ver aplicaciones corriendo
```powershell
docker exec -u hadoop hadoop-master yarn application -list
```

### Ver aplicaciones finalizadas
```powershell
docker exec -u hadoop hadoop-master yarn application -list -appStates FINISHED
```

---

## 2. Pruebas Rápidas (1-2 minutos)

### Estimar Pi (versión corta)
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 5 1000"
```
- **5 maps** con **1,000 muestras** cada uno
- **Tiempo**: ~30-60 segundos
- **Qué verifica**: Procesamiento CPU distribuido

### Generar datos aleatorios
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar randomwriter /random-data"
```
- **Tiempo**: ~1 minuto
- **Qué verifica**: Escritura en HDFS

### Grep en archivos grandes
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar grep /random-data /grep-output 'dfs[a-z.]+'"
```
- **Tiempo**: ~30-60 segundos
- **Qué verifica**: Lectura y búsqueda distribuida

---

## 3. Pruebas Intermedias (2-10 minutos)

### WordCount con datos propios
```powershell
# Crear datos de prueba
docker exec -u hadoop hadoop-master bash -c "echo 'Hello Hadoop World' > /tmp/test.txt && hdfs dfs -put /tmp/test.txt /test-input.txt"

# Ejecutar WordCount
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount /test-input.txt /wordcount-output"

# Ver resultado
docker exec -u hadoop hadoop-master hdfs dfs -cat /wordcount-output/part-r-00000
```

### Estimar Pi (versión media)
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 20 10000"
```
- **20 maps** con **10,000 muestras** cada uno
- **Tiempo**: ~2-3 minutos
- **Precisión alta**: ~3.141XX

### TestDFSIO - Benchmark de Escritura
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -write -nrFiles 5 -fileSize 50MB"
```
- **Escribe 5 archivos** de **50 MB** cada uno
- **Tiempo**: ~2-5 minutos
- **Muestra**: MB/s de throughput de escritura

### TestDFSIO - Benchmark de Lectura
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -read -nrFiles 5 -fileSize 50MB"
```
- **Lee los 5 archivos** creados antes
- **Tiempo**: ~1-3 minutos
- **Muestra**: MB/s de throughput de lectura

---

## 4. Pruebas Avanzadas (10+ minutos)

### Estimar Pi con alta precisión
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 50 100000"
```
- **50 maps** con **100,000 muestras** cada uno
- **Total**: 5,000,000 puntos
- **Tiempo**: ~5-10 minutos
- **Resultado**: Pi con 5 decimales de precisión

### TeraGen - Generar dataset grande
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar teragen 10000000 /terasort-input"
```
- **Genera 1 GB** de datos (10 millones de registros de 100 bytes)
- **Tiempo**: ~3-5 minutos

### TeraSort - Ordenar dataset
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar terasort /terasort-input /terasort-output"
```
- **Ordena 1 GB** de datos
- **Tiempo**: ~5-10 minutos
- **Benchmark estándar** de Hadoop

### TeraValidate - Validar ordenamiento
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar teravalidate /terasort-output /terasort-validate"
```
- **Verifica** que TeraSort funcionó correctamente
- **Tiempo**: ~2-3 minutos

### TestDFSIO con archivos grandes
```powershell
# Escritura
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -write -nrFiles 10 -fileSize 100MB"

# Lectura
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -read -nrFiles 10 -fileSize 100MB"
```
- **10 archivos de 100 MB** = 1 GB total
- **Tiempo**: ~5-10 minutos cada uno

---

## 5. Comandos de HDFS

### Ver archivos en HDFS
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -ls /
```

### Ver estructura completa
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -ls -R /
```

### Ver contenido de un archivo
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -cat /demo/output/part-r-00000
```

### Ver primeras líneas
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -cat /demo/output/part-r-00000 | head -20
```

### Crear directorio
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -mkdir /mi-directorio
```

### Subir archivo desde local
```powershell
# Primero crear archivo en el contenedor
docker exec -u hadoop hadoop-master bash -c "echo 'Prueba de Hadoop' > /tmp/miarchivo.txt"

# Luego subirlo a HDFS
docker exec -u hadoop hadoop-master hdfs dfs -put /tmp/miarchivo.txt /mi-directorio/
```

### Descargar archivo desde HDFS
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -get /demo/output/part-r-00000 /tmp/resultado-local.txt
```

### Ver tamaño de archivos/directorios
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -du -h /
```

### Eliminar archivo/directorio
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -rm -r /directorio-a-eliminar
```

### Ver espacio usado en HDFS
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -df -h
```

---

## 6. Monitoreo Durante Ejecución

### Ver tareas corriendo en tiempo real
```powershell
docker exec -u hadoop hadoop-master yarn application -list -appStates RUNNING
```

### Ver uso de recursos por aplicación
```powershell
docker exec -u hadoop hadoop-master yarn top
```
**Nota**: Presiona `Ctrl+C` para salir

### Ver logs de una aplicación específica
```powershell
# Primero obtén el Application ID (ej: application_1768261826278_0002)
docker exec -u hadoop hadoop-master yarn logs -applicationId application_1768261826278_0002
```

### Ver estado detallado de un job
```powershell
docker exec -u hadoop hadoop-master yarn application -status application_1768261826278_0002
```

### Ver contenedores corriendo
```powershell
docker exec -u hadoop hadoop-master yarn container -list hadoop-master:35267
```

### Ver métricas de nodos
```powershell
docker exec -u hadoop hadoop-master yarn node -status hadoop-master:35267
```

---

## 7. Verificar Salud del Cluster

### HDFS saludable
```powershell
docker exec -u hadoop hadoop-master hdfs fsck /
```
**Busca**: "Status: HEALTHY"

### HDFS detallado con bloques
```powershell
docker exec -u hadoop hadoop-master hdfs fsck / -files -blocks -locations
```

### Ver DataNodes activos
```powershell
docker exec -u hadoop hadoop-master hdfs dfsadmin -printTopology
```

### Ver si hay bloques corruptos
```powershell
docker exec -u hadoop hadoop-master hdfs fsck / -list-corruptfileblocks
```

---

## 8. Limpiar Datos de Pruebas

### Limpiar resultados de TestDFSIO
```powershell
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -clean"
```

### Eliminar datos de TeraSort
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -rm -r /terasort-input /terasort-output /terasort-validate
```

### Eliminar todos los directorios de prueba
```powershell
docker exec -u hadoop hadoop-master hdfs dfs -rm -r /demo /test-input.txt /wordcount-output /grep-output /random-data
```

---

## 9. Acceder a Interfaces Web

### Abrir en tu navegador:

**ResourceManager** - Ver jobs y recursos
```
http://localhost:8088
```
- Ver aplicaciones corriendo/finalizadas
- Métricas de uso de CPU/memoria
- Estado de nodos

**NameNode** - Explorar HDFS
```
http://localhost:9870
```
- Ver archivos en HDFS
- Descargar archivos
- Ver salud del sistema de archivos

**Job History Server** - Ver historial detallado
```
http://localhost:19888
```
- Detalles de cada job ejecutado
- Tiempos de Map/Reduce
- Logs de ejecución

---

## 10. Script de Monitoreo Automático

### Ver estado cada 5 segundos
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\monitor-cluster.ps1
```

### O crear tu propio script simple:
```powershell
# Guardar como monitor-simple.ps1
while ($true) {
    Clear-Host
    Write-Host "=== ESTADO DEL CLUSTER ===" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Procesos:" -ForegroundColor Yellow
    docker exec -u hadoop hadoop-master jps
    Write-Host ""

    Write-Host "Nodos YARN:" -ForegroundColor Yellow
    docker exec -u hadoop hadoop-master yarn node -list | Select-Object -First 5
    Write-Host ""

    Write-Host "Apps corriendo:" -ForegroundColor Yellow
    docker exec -u hadoop hadoop-master yarn application -list -appStates RUNNING | Select-Object -First 5

    Start-Sleep -Seconds 5
}
```

---

## 11. Secuencia Recomendada para Pruebas Completas

### Prueba Rápida (5 minutos total)
```powershell
# 1. Verificar estado
docker exec -u hadoop hadoop-master jps
docker exec -u hadoop hadoop-master yarn node -list

# 2. Prueba rápida de Pi
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 5 1000"

# 3. Ver en web
# Abre http://localhost:8088
```

### Prueba Completa (30 minutos total)
```powershell
# 1. Pi Estimation
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 20 10000"

# 2. TestDFSIO Escritura
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -write -nrFiles 5 -fileSize 50MB"

# 3. TestDFSIO Lectura
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -read -nrFiles 5 -fileSize 50MB"

# 4. TeraGen (generar 1GB)
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar teragen 10000000 /terasort-input"

# 5. TeraSort (ordenar 1GB)
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar terasort /terasort-input /terasort-output"

# 6. TeraValidate (validar)
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar teravalidate /terasort-output /terasort-validate"

# 7. Ver todos los resultados en http://localhost:8088 y http://localhost:19888
```

---

## 12. Solución de Problemas

### Si no puedes acceder a las interfaces web
```powershell
# Verificar que Hadoop está corriendo
docker exec -u hadoop hadoop-master jps

# Si no ves procesos, reiniciar Hadoop
powershell -ExecutionPolicy Bypass -File .\scripts\configure-and-start-hadoop.ps1

# Probar conexión
powershell -ExecutionPolicy Bypass -File .\test-web.ps1
```

### Si un job falla
```powershell
# Ver logs de la aplicación
docker exec -u hadoop hadoop-master yarn logs -applicationId <APPLICATION_ID>

# Ver estado detallado
docker exec -u hadoop hadoop-master yarn application -status <APPLICATION_ID>

# Ver salud de HDFS
docker exec -u hadoop hadoop-master hdfs fsck /
```

### Si HDFS está lleno
```powershell
# Ver uso
docker exec -u hadoop hadoop-master hdfs dfs -df -h

# Limpiar archivos antiguos
docker exec -u hadoop hadoop-master hdfs dfs -rm -r /directorio-grande
```

---

## Resumen de Comandos Esenciales

```powershell
# Estado
docker exec -u hadoop hadoop-master jps
docker exec -u hadoop hadoop-master yarn node -list

# Prueba rápida
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 5 1000"

# Ver HDFS
docker exec -u hadoop hadoop-master hdfs dfs -ls -R /

# Ver apps
docker exec -u hadoop hadoop-master yarn application -list -appStates FINISHED

# Web interfaces
http://localhost:8088  # ResourceManager
http://localhost:9870  # NameNode
http://localhost:19888 # Job History
```

---

**Tips**:
- Copia y pega estos comandos directamente en PowerShell
- Monitorea las interfaces web mientras ejecutas los trabajos
- Empieza con pruebas rápidas antes de las largas
- Usa `Ctrl+C` para cancelar un comando si tarda demasiado
