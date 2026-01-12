# Comandos Rápidos para Monitoreo de Hadoop

## Monitoreo en Tiempo Real

### Script de Monitoreo Automático
```powershell
# Ejecutar monitor en tiempo real (actualiza cada 5 segundos)
powershell -ExecutionPolicy Bypass -File .\scripts\monitor-cluster.ps1
```

## Comandos Básicos

### Ver Estado de Nodos

```bash
# Ver los 3 nodos YARN
docker exec -u hadoop hadoop-master yarn node -list

# Ver detalles de todos los nodos (incluso inactivos)
docker exec -u hadoop hadoop-master yarn node -list -all

# Ver estado detallado de un nodo específico
docker exec -u hadoop hadoop-master yarn node -status <node-id>
```

### Ver Aplicaciones

```bash
# Aplicaciones en ejecución
docker exec -u hadoop hadoop-master yarn application -list -appStates RUNNING

# Todas las aplicaciones (incluyendo completadas)
docker exec -u hadoop hadoop-master yarn application -list -appStates ALL

# Estado de una aplicación específica
docker exec -u hadoop hadoop-master yarn application -status <application-id>

# Logs de una aplicación
docker exec -u hadoop hadoop-master yarn logs -applicationId <application-id>
```

### Estado de HDFS

```bash
# Reporte completo de HDFS
docker exec -u hadoop hadoop-master hdfs dfsadmin -report

# Solo DataNodes activos
docker exec -u hadoop hadoop-master hdfs dfsadmin -report | grep -A 20 "Live datanodes"

# Topología del cluster
docker exec -u hadoop hadoop-master hdfs dfsadmin -printTopology

# Espacio usado en HDFS
docker exec -u hadoop hadoop-master hdfs dfs -df -h

# Uso por directorio
docker exec -u hadoop hadoop-master hdfs dfs -du -h /
```

### Ver Procesos Activos

```bash
# Procesos en master
docker exec -u hadoop hadoop-master jps

# Procesos en worker1
docker exec hadoop-worker1 jps

# Procesos en worker2
docker exec hadoop-worker2 jps

# Todos los nodos a la vez
docker exec -u hadoop hadoop-master jps && \
docker exec hadoop-worker1 jps && \
docker exec hadoop-worker2 jps
```

## Análisis de Rendimiento

### Ver Métricas de Recursos

```bash
# Uso de CPU y memoria de contenedores Docker
docker stats

# Uso de recursos en cada nodo YARN
docker exec -u hadoop hadoop-master bash -c "
  for node in hadoop-master:44773 hadoop-worker1:35425 hadoop-worker2:37847; do
    echo \"=== \$node ===\"
    yarn node -status \$node 2>/dev/null | grep -E '(Memory|CPU|Resource Utilization)'
    echo ''
  done
"
```

### Ver Información de Jobs Completados

```bash
# Listar jobs completados
docker exec -u hadoop hadoop-master yarn application -list -appStates FINISHED

# Ver detalles de un job
docker exec -u hadoop hadoop-master yarn application -status <app-id>

# Ver métricas de rendimiento de un job
docker exec -u hadoop hadoop-master mapred job -history all <job-id>
```

## Pruebas de Rendimiento

### Benchmark Rápido: Pi Estimation

```bash
# Ejecutar estimación de Pi (verás distribución entre nodos)
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 10 1000
```

### WordCount con Archivo Grande

```bash
# Crear archivo de prueba
docker exec -u hadoop hadoop-master bash -c "
  for i in {1..10000}; do
    echo 'Hadoop procesa datos en paralelo entre múltiples nodos'
  done > /tmp/bigfile.txt
"

# Subir a HDFS
docker exec -u hadoop hadoop-master hdfs dfs -put /tmp/bigfile.txt /input/

# Ejecutar WordCount
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input /output

# Ver resultados
docker exec -u hadoop hadoop-master hdfs dfs -cat /output/part-r-00000 | sort -k2 -nr | head -20
```

### Benchmark TestDFSIO (Lectura/Escritura)

```bash
# Benchmark de ESCRITURA
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -write -nrFiles 10 -fileSize 100MB

# Benchmark de LECTURA
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -read -nrFiles 10 -fileSize 100MB

# Limpiar archivos de prueba
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -clean
```

## Verificar Comunicación entre Nodos

### Test de Conectividad

```bash
# Desde master a worker1
docker exec -u hadoop hadoop-master ssh hadoop-worker1 'hostname'

# Desde master a worker2
docker exec -u hadoop hadoop-master ssh hadoop-worker2 'hostname'

# Ping entre nodos
docker exec hadoop-master ping -c 3 hadoop-worker1
docker exec hadoop-master ping -c 3 hadoop-worker2
```

### Ver Logs de Comunicación

```bash
# Logs del NameNode (comunicación con DataNodes)
docker exec hadoop-master tail -f /opt/hadoop/logs/hadoop-hadoop-namenode-hadoop-master.log

# Logs del ResourceManager (comunicación con NodeManagers)
docker exec hadoop-master tail -f /opt/hadoop/logs/hadoop-hadoop-resourcemanager-hadoop-master.log

# Logs de un NodeManager
docker exec hadoop-worker1 tail -f /opt/hadoop/logs/yarn-hadoop-nodemanager-hadoop-worker1.log
```

## Ver Información de Archivos en HDFS

### Análisis de Distribución de Bloques

```bash
# Ver dónde están almacenados los bloques de un archivo
docker exec -u hadoop hadoop-master hdfs fsck /ruta/archivo -files -blocks -locations

# Verificar salud de HDFS
docker exec -u hadoop hadoop-master hdfs fsck /

# Ver archivos sin suficientes réplicas
docker exec -u hadoop hadoop-master hdfs fsck / | grep "Under replicated"
```

## Gestión del Cluster

### Reiniciar Servicios

```bash
# Reiniciar HDFS
docker exec -u hadoop hadoop-master stop-dfs.sh
docker exec -u hadoop hadoop-master start-dfs.sh

# Reiniciar YARN
docker exec -u hadoop hadoop-master stop-yarn.sh
docker exec -u hadoop hadoop-master start-yarn.sh

# Reiniciar todo
powershell -ExecutionPolicy Bypass -File .\scripts\restart-hadoop-full.ps1
```

### Limpiar Datos de Prueba

```bash
# Eliminar directorios de prueba en HDFS
docker exec -u hadoop hadoop-master hdfs dfs -rm -r /input /output /wordcount-demo /TestDFSIO*

# Limpiar archivos temporales locales
docker exec hadoop-master bash -c "rm -rf /tmp/*.txt"
```

## Interfaces Web (Más Visual)

Abre en tu navegador:

- **NameNode**: http://localhost:9870
  - Ve DataNodes activos
  - Navegador de archivos HDFS
  - Métricas de capacidad

- **ResourceManager**: http://localhost:8088
  - **Pestaña "Nodes"**: Los 3 nodos activos
  - **Pestaña "Applications"**: Jobs ejecutándose
  - Click en un job para ver detalles de rendimiento

- **Job History Server**: http://localhost:19888
  - Historial completo de jobs
  - Métricas detalladas de Map/Reduce
  - Distribución de trabajo entre nodos

- **NodeManagers**:
  - http://localhost:8042 (master)
  - http://localhost:8043 (worker2)

## Ejemplos de Uso Combinado

### Monitorear un Job en Ejecución

```bash
# 1. Ejecutar job en background
docker exec -u hadoop hadoop-master bash -c "
  hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 20 10000 &
"

# 2. Ver aplicaciones corriendo
docker exec -u hadoop hadoop-master yarn application -list -appStates RUNNING

# 3. Ver distribución en nodos
docker exec -u hadoop hadoop-master yarn node -list

# 4. Ver en tiempo real
watch -n 2 "docker exec -u hadoop hadoop-master yarn application -list -appStates RUNNING"
```

### Análisis Post-Ejecución

```bash
# Después de ejecutar un job, obtén el application-id y ejecuta:

APP_ID="application_XXXXX_XXXX"

# Ver estado final
docker exec -u hadoop hadoop-master yarn application -status $APP_ID

# Ver logs completos
docker exec -u hadoop hadoop-master yarn logs -applicationId $APP_ID

# Ver en la interfaz web
echo "http://localhost:19888/jobhistory/job/job_XXXXX_XXXX"
```

## Tips para Optimización

1. **Monitorear constantemente** las interfaces web durante la ejecución de jobs
2. **Revisar logs** cuando hay fallos para diagnosticar problemas
3. **Usar TestDFSIO** para verificar rendimiento de I/O
4. **Ejecutar benchmarks** periódicamente para medir mejoras
5. **Verificar balanceo** de carga entre los 3 nodos

## Comandos de un Vistazo

```bash
# Estado general
docker exec -u hadoop hadoop-master yarn node -list
docker exec -u hadoop hadoop-master hdfs dfsadmin -report

# Ejecutar prueba
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 10 1000

# Ver resultados
docker exec -u hadoop hadoop-master yarn application -list -appStates ALL

# Monitoreo continuo
powershell -ExecutionPolicy Bypass -File .\scripts\monitor-cluster.ps1
```

---

**Para más detalles**, consulta `GUIA_MONITOREO_RENDIMIENTO.md`
