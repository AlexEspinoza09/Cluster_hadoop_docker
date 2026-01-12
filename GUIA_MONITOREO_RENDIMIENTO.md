# Guía de Monitoreo y Rendimiento de Hadoop Cluster

Esta guía te mostrará cómo monitorear y analizar el rendimiento y comunicación entre los nodos de tu cluster Hadoop.

## 1. Interfaces Web de Monitoreo

### NameNode Web UI (HDFS)
**URL**: http://localhost:9870

**Qué puedes ver:**
- Estado general de HDFS
- Número de DataNodes activos
- Capacidad total, usada y disponible
- Número de archivos y bloques
- Live Nodes vs Dead Nodes
- Navegador de archivos HDFS

**Métricas importantes:**
- **Configured Capacity**: Capacidad total del cluster
- **DFS Used**: Espacio usado en HDFS
- **DFS Remaining**: Espacio disponible
- **Live Nodes**: Nodos DataNode activos
- **Block Pool Used**: Uso de bloques

### ResourceManager Web UI (YARN)
**URL**: http://localhost:8088

**Qué puedes ver:**
- Aplicaciones en ejecución y completadas
- Estado de NodeManagers
- Métricas de recursos (CPU, memoria)
- Cola de trabajos
- Historial de aplicaciones

**Métricas importantes:**
- **Cluster Metrics**: Memoria total/usada, VCores total/usado
- **Active Nodes**: Nodos trabajadores activos
- **Applications**: Running, Pending, Completed, Failed
- **Memory Used**: Uso de memoria del cluster

### Job History Server
**URL**: http://localhost:19888

**Qué puedes ver:**
- Historial de trabajos MapReduce
- Tiempo de ejecución de cada job
- Detalles de Map y Reduce tasks
- Logs de aplicaciones

### NodeManager Web UI
**URLs**:
- http://localhost:8042 (hadoop-master)
- http://localhost:8043 (hadoop-worker1)
- http://localhost:9865 (hadoop-worker2)

**Qué puedes ver:**
- Containers en ejecución
- Logs de aplicaciones en ese nodo
- Uso de recursos del nodo

## 2. Comandos CLI para Monitoreo

### Ver Estado de HDFS

```bash
# Reporte completo de HDFS
docker exec -u hadoop hadoop-master hdfs dfsadmin -report

# Ver DataNodes vivos
docker exec -u hadoop hadoop-master hdfs dfsadmin -printTopology

# Verificar salud de HDFS
docker exec -u hadoop hadoop-master hdfs dfsadmin -report | grep -A 5 "Live datanodes"

# Ver archivos corruptos
docker exec -u hadoop hadoop-master hdfs fsck / | grep -B 3 "CORRUPT"
```

### Ver Estado de YARN

```bash
# Listar todos los nodos
docker exec -u hadoop hadoop-master yarn node -list

# Ver estado de nodos con detalles
docker exec -u hadoop hadoop-master yarn node -list -all

# Ver métricas de cluster
docker exec -u hadoop hadoop-master yarn node -status <node-id>

# Listar aplicaciones
docker exec -u hadoop hadoop-master yarn application -list

# Ver logs de una aplicación
docker exec -u hadoop hadoop-master yarn logs -applicationId <app-id>
```

### Verificar Procesos en Cada Nodo

```bash
# Ver procesos Java en master
docker exec -u hadoop hadoop-master jps

# Ver procesos en worker1
docker exec hadoop-worker1 jps

# Ver procesos en worker2
docker exec hadoop-worker2 jps
```

## 3. Pruebas de Rendimiento

### Prueba 1: Benchmark de Lectura/Escritura HDFS (TestDFSIO)

```bash
# Acceder al contenedor master
docker exec -it hadoop-master bash

# Cambiar a usuario hadoop
su - hadoop

# Benchmark de ESCRITURA
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -write -nrFiles 10 -fileSize 100MB

# Benchmark de LECTURA
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -read -nrFiles 10 -fileSize 100MB

# Limpiar archivos de prueba
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -clean
```

**Métricas que obtendrás:**
- Throughput (MB/s)
- Average IO rate (MB/s)
- Tiempo promedio de I/O
- Tiempo total de ejecución

### Prueba 2: WordCount (MapReduce)

```bash
# Crear archivo de entrada
echo "Hadoop es un framework distribuido
Hadoop procesa grandes volúmenes de datos
MapReduce es el modelo de programación de Hadoop
HDFS es el sistema de archivos de Hadoop" > /tmp/input.txt

# Duplicar el contenido para hacerlo más grande
for i in {1..10000}; do cat /tmp/input.txt; done > /tmp/bigfile.txt

# Subir a HDFS
hdfs dfs -mkdir -p /input
hdfs dfs -put /tmp/bigfile.txt /input/

# Ejecutar WordCount
time hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input/bigfile.txt /output

# Ver resultados
hdfs dfs -cat /output/part-r-00000 | head -20

# Limpiar
hdfs dfs -rm -r /input /output
```

### Prueba 3: TeraSort (Benchmark estándar de Hadoop)

```bash
# Generar 1GB de datos aleatorios
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  teragen 10000000 /teragen-input

# Ordenar los datos (TeraSort)
time hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  terasort /teragen-input /terasort-output

# Validar el ordenamiento
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  teravalidate /terasort-output /teravalidate-output

# Limpiar
hdfs dfs -rm -r /teragen-input /terasort-output /teravalidate-output
```

## 4. Monitoreo de Comunicación entre Nodos

### Ver Topología del Cluster

```bash
docker exec -u hadoop hadoop-master hdfs dfsadmin -printTopology
```

Esto muestra la jerarquía de racks y nodos.

### Verificar Conectividad SSH entre Nodos

```bash
# Desde master a worker1
docker exec -u hadoop hadoop-master ssh hadoop-worker1 'hostname'

# Desde master a worker2
docker exec -u hadoop hadoop-master ssh hadoop-worker2 'hostname'
```

### Ver Logs de Comunicación

```bash
# Logs del NameNode (comunicación con DataNodes)
docker exec hadoop-master tail -f /opt/hadoop/logs/hadoop-hadoop-namenode-hadoop-master.log

# Logs del ResourceManager (comunicación con NodeManagers)
docker exec hadoop-master tail -f /opt/hadoop/logs/hadoop-hadoop-resourcemanager-hadoop-master.log

# Logs de un DataNode
docker exec hadoop-worker1 tail -f /opt/hadoop/logs/hadoop-hadoop-datanode-hadoop-worker1.log
```

## 5. Métricas de Rendimiento a Monitorear

### HDFS
- **Throughput**: Velocidad de lectura/escritura (MB/s)
- **Block Replication**: Número de réplicas de cada bloque
- **Under-replicated Blocks**: Bloques que no tienen suficientes réplicas
- **Corrupted Blocks**: Bloques corruptos
- **DataNode Heartbeats**: Latencia de comunicación entre DataNodes y NameNode

### YARN
- **Container Allocation Time**: Tiempo para asignar un container
- **Application Completion Time**: Tiempo total de ejecución de aplicaciones
- **Node Utilization**: % de CPU y memoria usados por nodo
- **Failed Containers**: Containers que fallaron durante la ejecución

### MapReduce
- **Map Task Time**: Tiempo promedio de tareas Map
- **Reduce Task Time**: Tiempo promedio de tareas Reduce
- **Shuffle Time**: Tiempo de transferencia de datos entre Map y Reduce
- **Job Completion Time**: Tiempo total del job

## 6. Análisis de Archivos en HDFS

### Ver dónde están almacenados los bloques

```bash
# Ver información de bloques de un archivo
hdfs fsck /ruta/archivo -files -blocks -locations

# Ver estadísticas de un directorio
hdfs fsck /directorio -files -blocks -locations | grep -A 10 "Status"
```

Esto muestra:
- En qué DataNodes están los bloques
- Número de réplicas
- Tamaño de bloques
- Estado de replicación

### Ver estadísticas de uso

```bash
# Uso de espacio por directorio
hdfs dfs -du -h /

# Resumen de uso
hdfs dfs -df -h
```

## 7. Comandos para Troubleshooting

```bash
# Ver nodos muertos
hdfs dfsadmin -report | grep -A 10 "Dead datanodes"

# Verificar el modo seguro
hdfs dfsadmin -safemode get

# Salir del modo seguro (si está atascado)
hdfs dfsadmin -safemode leave

# Balancear el cluster
hdfs balancer -threshold 10

# Ver configuración efectiva
hdfs getconf -confKey dfs.replication
```

## 8. Ejemplo Completo: Ejecutar un Job y Monitorear

```bash
# 1. Subir datos a HDFS
hdfs dfs -put /tmp/data.txt /input/

# 2. Ejecutar job en segundo plano y capturar el ID
hadoop jar myapp.jar MainClass /input /output &

# 3. Obtener el Application ID (aparecerá en el output)
# Ejemplo: application_1234567890123_0001

# 4. Monitorear en tiempo real
watch -n 2 "yarn application -status application_XXXXX_XXXX"

# 5. Ver logs en tiempo real
yarn logs -applicationId application_XXXXX_XXXX -log_files stdout

# 6. Ver en la interfaz web
# Ir a http://localhost:8088 y buscar la aplicación
```

## 9. Scripts de Monitoreo Automático

### Script para monitoreo continuo:

```bash
#!/bin/bash
# monitor-cluster.sh

while true; do
  clear
  echo "=== CLUSTER HADOOP STATUS ==="
  echo ""
  echo "HDFS Status:"
  hdfs dfsadmin -report | head -15
  echo ""
  echo "YARN Nodes:"
  yarn node -list
  echo ""
  echo "Applications:"
  yarn application -list -appStates RUNNING
  sleep 10
done
```

## 10. Tips de Optimización

1. **Para HDFS**:
   - Ajustar `dfs.blocksize` según tamaño de archivos
   - Monitorear `dfs.replication` para balance entre redundancia y espacio
   - Verificar que no haya bloques sub-replicados

2. **Para YARN**:
   - Ajustar `yarn.nodemanager.resource.memory-mb` según RAM disponible
   - Optimizar `yarn.scheduler.minimum-allocation-mb` para trabajos pequeños
   - Monitorear containers failed para detectar problemas

3. **Para MapReduce**:
   - Ajustar `mapreduce.map.memory.mb` y `mapreduce.reduce.memory.mb`
   - Optimizar número de mappers y reducers según datos
   - Usar compression para reducir I/O

## Resumen de Comandos Rápidos

```bash
# Estado general
docker exec -u hadoop hadoop-master hdfs dfsadmin -report
docker exec -u hadoop hadoop-master yarn node -list
docker exec -u hadoop hadoop-master jps

# Prueba rápida
docker exec -u hadoop hadoop-master hdfs dfs -put /tmp/test.txt /
docker exec -u hadoop hadoop-master hdfs fsck /test.txt -files -blocks -locations

# Ver aplicaciones
docker exec -u hadoop hadoop-master yarn application -list

# Ver logs
docker exec hadoop-master tail -f /opt/hadoop/logs/*.log
```
