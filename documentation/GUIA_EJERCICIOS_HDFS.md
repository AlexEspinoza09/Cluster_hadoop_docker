# GUÍA DE CONFIGURACIÓN Y VERIFICACIÓN - EJERCICIOS HDFS

Esta guía te ayudará a preparar y verificar tu cluster para los ejercicios de:
1. **Block Size en HDFS**
2. **Balanceamiento de bloques en HDFS**

---

## 1. ESTADO DEL CLÚSTER (REQUISITOS PREVIOS)

### 1.1 Verificar que el NameNode está activo

**Comando:**
```bash
docker exec -u hadoop hadoop-master jps | grep NameNode
```

**Resultado esperado:**
```
256 NameNode
```

**Alternativa - Ver procesos completos:**
```bash
docker exec -u hadoop hadoop-master jps
```

### 1.2 Verificar que los DataNodes están registrados

**Comando:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report"
```

**Resultado esperado:**
- Debe mostrar "Live datanodes (3):" o al menos "Live datanodes (2):"
- Cada DataNode debe mostrar estado "Decommission Status: Normal"

**Verificación rápida del número de DataNodes:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Live datanodes'"
```

**Estado actual de tu cluster:**
```
Live datanodes (3):
- hadoop-master (172.23.0.2:9866) - 1006.85 GB
- hadoop-worker1 (172.23.0.4:9866) - 1006.85 GB
- hadoop-worker2 (172.23.0.3:9866) - 1006.85 GB
Capacidad total: 2.95 TB
```
  
### 1.3 Verificar scripts start-dfs.sh y stop-dfs.sh

**Verificar existencia:**
```bash
docker exec -u hadoop hadoop-master ls -la /opt/hadoop/sbin/start-dfs.sh /opt/hadoop/sbin/stop-dfs.sh
```

**Probar detener HDFS:**
```bash
docker exec -u hadoop hadoop-master bash -c "stop-dfs.sh"
```

**Probar iniciar HDFS:**
```bash
docker exec -u hadoop hadoop-master bash -c "start-dfs.sh"
```

**Nota importante:** En tu cluster Docker, es mejor iniciar DataNodes individualmente usando:
```bash
# En master
docker exec -u hadoop hadoop-master bash -c "hdfs --daemon start datanode"

# En workers
docker exec -u hadoop hadoop-worker1 bash -c "hdfs --daemon start datanode"
docker exec -u hadoop hadoop-worker2 bash -c "hdfs --daemon start datanode"
```

### 1.4 Verificar comandos básicos de HDFS

**Listar raíz de HDFS:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -ls /"
```

**Reporte del sistema:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report"
```

### 1.5 Verificar configuración por defecto

**Tamaño de bloque por defecto:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs getconf -confKey dfs.blocksize"
```
**Resultado actual:** `134217728` (128 MB)

**Factor de replicación por defecto:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs getconf -confKey dfs.replication"
```
**Resultado actual:** `2`

---

## 2. CONFIGURACIÓN PARA EJERCICIO 1 (BLOCK SIZE)

### 2.1 Verificar que el cluster permite cambiar block size por comando

**El cluster permite cambiar block size usando `-D dfs.blocksize=X`**

**Comando de prueba (no ejecutar, solo verificar sintaxis):**
```bash
# Subir archivo con block size de 64 MB
hdfs dfs -D dfs.blocksize=67108864 -put archivo.txt /destino/

# Subir archivo con block size de 256 MB
hdfs dfs -D dfs.blocksize=268435456 -put archivo.txt /destino/
```

**El block size se especifica en bytes:**
| Tamaño | Bytes | Valor para -D |
|--------|-------|---------------|
| 32 MB | 33554432 | `-D dfs.blocksize=33554432` |
| 64 MB | 67108864 | `-D dfs.blocksize=67108864` |
| 128 MB | 134217728 | `-D dfs.blocksize=134217728` |
| 256 MB | 268435456 | `-D dfs.blocksize=268435456` |
| 512 MB | 536870912 | `-D dfs.blocksize=536870912` |
| 1 GB | 1073741824 | `-D dfs.blocksize=1073741824` |

### 2.2 Verificar que el cluster permite cambiar replicación por comando

**Comando de prueba:**
```bash
# Subir archivo con replicación 1
hdfs dfs -D dfs.replication=1 -put archivo.txt /destino/

# Cambiar replicación de archivo existente
hdfs dfs -setrep -w 3 /ruta/archivo.txt
```

### 2.3 Archivos de configuración

**Verificar core-site.xml:**
```bash
docker exec -u hadoop hadoop-master bash -c "cat /opt/hadoop/etc/hadoop/core-site.xml"
```

**Verificar hdfs-site.xml:**
```bash
docker exec -u hadoop hadoop-master bash -c "cat /opt/hadoop/etc/hadoop/hdfs-site.xml"
```

**Verificar archivo workers:**
```bash
docker exec -u hadoop hadoop-master bash -c "cat /opt/hadoop/etc/hadoop/workers"
```

**Contenido esperado de workers:**
```
hadoop-master
hadoop-worker1
hadoop-worker2
```

### 2.4 Comandos para comprobar bloques

**Ver tamaño de bloque de un archivo:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ruta/archivo -files -blocks"
```

**Ver información detallada de bloques y ubicación:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ruta/archivo -files -blocks -locations"
```

**Ver en qué DataNode está cada bloque:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ruta/archivo -files -blocks -locations | grep -E 'blk_|DatanodeInfoWithStorage'"
```

### 2.5 Comandos para el ejercicio de Block Size

#### Crear archivo de prueba grande (>1GB)

**Opción 1: Generar archivo de 1.5 GB con datos aleatorios:**
```bash
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/testfile_1.5gb bs=1M count=1536"
```

**Opción 2: Generar archivo de 2 GB:**
```bash
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/testfile_2gb bs=1M count=2048"
```

#### Subir archivo con block size personalizado

**Con block size de 64 MB:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=67108864 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio1/bs64mb/"
```

**Con block size de 128 MB:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=134217728 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio1/bs128mb/"
```

**Con block size de 256 MB:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=268435456 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio1/bs256mb/"
```

#### Leer archivo y medir tiempo (sin mostrar contenido)

**Medir tiempo de lectura:**
```bash
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio1/bs64mb/testfile_1.5gb > /dev/null"
```

**Alternativa con más precisión:**
```bash
docker exec -u hadoop hadoop-master bash -c "start=\$(date +%s.%N); hdfs dfs -cat /ejercicio1/bs64mb/testfile_1.5gb > /dev/null; end=\$(date +%s.%N); echo \"Tiempo: \$(echo \"\$end - \$start\" | bc) segundos\""
```

#### Verificar bloques creados

**Ver número de bloques:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio1/bs64mb/testfile_1.5gb -files -blocks | grep 'Total blocks'"
```

**Ver ubicación de bloques por DataNode:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio1/bs64mb/testfile_1.5gb -files -blocks -locations"
```

#### Eliminar archivo tras cada prueba

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio1/bs64mb"
```

### 2.6 Filtrar bloques por DataNode específico

**Ver bloques en hadoop-master:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations | grep 'hadoop-master'"
```

**Ver bloques en hadoop-worker1:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations | grep 'hadoop-worker1'"
```

**Ver bloques en hadoop-worker2:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations | grep 'hadoop-worker2'"
```

**Filtrar por IP:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations | grep '172.23.0.2'"  # master
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations | grep '172.23.0.3'"  # worker2
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations | grep '172.23.0.4'"  # worker1
```

---

## 3. CONFIGURACIÓN PARA EJERCICIO 2 (BALANCEAMIENTO)

### 3.1 Verificar DataNodes existentes

**Comando para ver exactamente cuántos DataNodes hay:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -c 'Name:'"
```

**Ver lista de DataNodes:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Name:'"
```

**Estado actual:**
```
Name: 172.23.0.2:9866 (hadoop-master)
Name: 172.23.0.3:9866 (hadoop-worker2)
Name: 172.23.0.4:9866 (hadoop-worker1)
```

### 3.2 Verificar espacio disponible por DataNode

**Ver espacio de cada DataNode:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -A 10 'Name:'"
```

**Resultado esperado:** Todos los DataNodes deben tener espacio similar (~917 GB disponible cada uno)

### 3.3 Fijar factor de replicación a 1

**Por qué es importante para balanceamiento:**
- Con replicación = 1, cada bloque existe en UN SOLO DataNode
- Esto permite observar cómo HDFS distribuye bloques entre DataNodes
- Con replicación > 1, los bloques se copian a múltiples nodos, lo que complica el análisis de distribución

**Comandos para subir con replicación 1:**
```bash
# Subir archivo con replicación 1
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.replication=1 -put /tmp/testfile /ruta/"

# Verificar replicación del archivo
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -stat %r /ruta/testfile"
```

### 3.4 Verificar distribución de bloques

#### Antes de insertar archivos

**Ver bloques por DataNode:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Num of Blocks'"
```

**Ver distribución detallada:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:'"
```

#### Después de insertar archivos

**Ver distribución de bloques de un archivo específico:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio2/testfile -files -blocks -locations"
```

**Contar bloques por DataNode:**
```bash
# Bloques en master
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c 'hadoop-master'"

# Bloques en worker1
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c 'hadoop-worker1'"

# Bloques en worker2
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c 'hadoop-worker2'"
```

### 3.5 Métricas para observar

#### Número de bloques por DataNode

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:'"
```

#### Espacio usado por DataNode

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|DFS Used:'"
```

#### Verificar distribución uniforme

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|DFS Used%:'"
```

**Distribución ideal:** Todos los DataNodes deberían mostrar % de uso similar

### 3.6 Comandos para ejercicio de Balanceamiento

#### Crear directorio para ejercicio
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -mkdir -p /ejercicio2"
```

#### Generar archivo de prueba
```bash
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/balance_test bs=1M count=512"
```

#### Subir con diferentes tamaños de bloque y replicación 1

**Block size 64 MB:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=67108864 -D dfs.replication=1 -put /tmp/balance_test /ejercicio2/bs64mb_rep1"
```

**Block size 128 MB:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=134217728 -D dfs.replication=1 -put /tmp/balance_test /ejercicio2/bs128mb_rep1"
```

**Block size 256 MB:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=268435456 -D dfs.replication=1 -put /tmp/balance_test /ejercicio2/bs256mb_rep1"
```

#### Ver distribución de cada archivo

```bash
# Para 64 MB blocks
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio2/bs64mb_rep1 -files -blocks -locations"

# Para 128 MB blocks
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio2/bs128mb_rep1 -files -blocks -locations"

# Para 256 MB blocks
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio2/bs256mb_rep1 -files -blocks -locations"
```

#### Forzar rebalanceo del cluster

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs balancer -threshold 10"
```

**Nota:** El threshold indica el porcentaje máximo de diferencia entre DataNodes

---

## 4. VALIDACIONES OBLIGATORIAS

### 4.1 Verificar que NO está en modo seguro

**Comando:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -safemode get"
```

**Resultado esperado:** `Safe mode is OFF`

**Si está en modo seguro, desactivarlo:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -safemode leave"
```

### 4.2 Verificar que no hay DataNodes muertos

**Comando:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Dead datanodes|Live datanodes'"
```

**Resultado esperado:**
```
Live datanodes (3):
```

**Si muestra Dead datanodes, verificar estado:**
```bash
docker exec -u hadoop hadoop-worker1 jps | grep DataNode
docker exec -u hadoop hadoop-worker2 jps | grep DataNode
```

### 4.3 Limpiar residuos de pruebas anteriores

**Listar archivos en HDFS:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -ls -R /"
```

**Eliminar directorios de ejercicios anteriores:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio1 /ejercicio2 2>/dev/null; echo 'Limpieza completada'"
```

**Verificar que está limpio:**
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -ls /"
```

### 4.4 Verificar que cambios de block size son POR ARCHIVO

**Importante:** Cambiar el block size con `-D dfs.blocksize=X` solo afecta al archivo que se está subiendo, NO cambia la configuración global del cluster.

**Verificación:**
```bash
# Subir archivo con block size 64MB
docker exec -u hadoop hadoop-master bash -c "echo 'test' > /tmp/test1.txt && hdfs dfs -D dfs.blocksize=67108864 -put /tmp/test1.txt /test1.txt"

# Subir otro archivo SIN especificar block size (usará default 128MB)
docker exec -u hadoop hadoop-master bash -c "echo 'test2' > /tmp/test2.txt && hdfs dfs -put /tmp/test2.txt /test2.txt"

# Verificar que cada archivo tiene su propio block size
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /test1.txt -files -blocks"
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /test2.txt -files -blocks"

# Limpiar
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm /test1.txt /test2.txt"
```

**Conclusión:** El block size especificado por comando solo aplica al archivo específico.

---

## 5. DIFERENCIAS DOCKER VS VM (JUSTIFICACIÓN ACADÉMICA)

### 5.1 Diferencias técnicas

| Aspecto | Máquinas Virtuales | Contenedores Docker |
|---------|-------------------|---------------------|
| **Virtualización** | Completa (hypervisor) | A nivel de SO (namespaces) |
| **Sistema Operativo** | SO completo por VM | Kernel compartido |
| **Recursos** | ~500 MB RAM por VM | ~50 MB por contenedor |
| **Inicio** | 1-2 minutos | 5-10 segundos |
| **Aislamiento** | Hardware virtualizado | Namespaces y cgroups |
| **Red** | Virtual (NAT/Bridge) | Bridge Docker nativo |
| **Almacenamiento** | Disco virtual (.vmdk/.vdi) | Layers y volúmenes |

### 5.2 Por qué NO afectan a los ejercicios de HDFS

**1. HDFS es agnóstico al entorno de ejecución:**
- HDFS solo ve procesos Java (NameNode, DataNode)
- No distingue si el proceso corre en VM, contenedor o bare metal
- La comunicación es por red TCP/IP en ambos casos

**2. Los bloques funcionan igual:**
- El tamaño de bloque se define en la configuración de HDFS
- Los bloques se almacenan en el sistema de archivos local (sea virtual o no)
- El algoritmo de distribución es el mismo

**3. La red funciona equivalentemente:**
- Docker bridge simula una red privada igual que NAT en VMs
- Los DataNodes se registran con el NameNode usando TCP/IP
- La comunicación entre nodos es idéntica

**4. El balanceamiento no depende del tipo de virtualización:**
- El balanceador de HDFS distribuye bloques basándose en:
  - Espacio disponible en cada DataNode
  - Número de bloques por DataNode
  - Topología de red (racks)
- Ninguno de estos factores cambia entre Docker y VMs

### 5.3 Por qué los resultados son válidos

**Para ejercicio de Block Size:**
- El comportamiento de bloques es idéntico
- El número de bloques creados será el mismo
- Los tiempos de lectura serán proporcionales (aunque absolutos pueden diferir)
- La distribución de bloques entre DataNodes será igual

**Para ejercicio de Balanceamiento:**
- Los DataNodes tienen espacio similar (verificado: ~917 GB cada uno)
- El algoritmo de distribución de HDFS funciona igual
- El rebalanceo con `hdfs balancer` produce los mismos resultados
- Las métricas de distribución son comparables

### 5.4 Diferencias que podrían afectar (pero no invalidan)

| Diferencia | Impacto | Mitigación |
|------------|---------|------------|
| Rendimiento I/O | Tiempos absolutos pueden variar | Usar tiempos relativos para comparar |
| Latencia de red | Más baja en Docker (~0.2ms) que VMs (~1-5ms) | Despreciable para HDFS |
| Espacio de disco | Docker usa mismo disco físico | Cada DataNode ve mismo espacio (correcto) |

**Conclusión:** Los ejercicios de Block Size y Balanceamiento producirán resultados funcionalmente equivalentes a un cluster en VMs. Los conceptos teóricos que se demuestran son idénticos.

---

## 6. RESUMEN DE COMANDOS ESENCIALES

### Para Block Size

```bash
# Crear archivo de prueba (1.5 GB)
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/testfile bs=1M count=1536"

# Subir con block size específico
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.blocksize=67108864 -D dfs.replication=1 -put /tmp/testfile /ejercicio/archivo"

# Ver bloques
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio/archivo -files -blocks -locations"

# Medir tiempo de lectura
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio/archivo > /dev/null"

# Eliminar
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio"
```

### Para Balanceamiento

```bash
# Ver estado de DataNodes
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report"

# Ver distribución de bloques
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:|DFS Used:'"

# Ejecutar balanceador
docker exec -u hadoop hadoop-master bash -c "hdfs balancer -threshold 10"
```

### Validaciones

```bash
# Estado del cluster
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -safemode get"
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Live datanodes'"

# Limpiar
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio1 /ejercicio2 2>/dev/null"
```

---

## 7. ESTADO ACTUAL DE TU CLUSTER

**Verificado y listo para ejercicios:**

| Componente | Estado | Valor |
|------------|--------|-------|
| NameNode | ✅ Activo | hadoop-master |
| DataNodes | ✅ 3 activos | master, worker1, worker2 |
| Capacidad total | ✅ | 2.95 TB |
| Block size default | ✅ | 128 MB |
| Replicación default | ✅ | 2 |
| Safe mode | ✅ OFF | - |
| HDFS | ✅ Limpio | Sin residuos |

**Tu cluster está listo para ejecutar los ejercicios de Block Size y Balanceamiento.**

---

**IMPORTANTE:** Antes de cada sesión de ejercicios, ejecuta:

```bash
# Verificar DataNodes activos
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Live datanodes'"

# Si no hay 3 DataNodes, reiniciarlos:
docker exec -u hadoop hadoop-master bash -c "hdfs --daemon start datanode"
docker exec -u hadoop hadoop-worker1 bash -c "hdfs --daemon start datanode"
docker exec -u hadoop hadoop-worker2 bash -c "hdfs --daemon start datanode"
```
