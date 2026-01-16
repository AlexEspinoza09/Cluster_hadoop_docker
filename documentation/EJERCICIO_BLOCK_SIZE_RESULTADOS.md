# EJERCICIO BLOCK SIZE EN HDFS - RESULTADOS Y PASOS PARA REPLICAR

**Fecha de ejecución**: 16 de enero de 2026
**Cluster**: 3 nodos (1 master + 2 workers)
**Archivo de prueba**: 1.5 GB (1,610,612,736 bytes)

---

## RESUMEN DE RESULTADOS

### Tabla Comparativa de Block Sizes

| Block Size | Bytes | Bloques Creados | Tiempo Subida | Tiempo Lectura |
|------------|-------|-----------------|---------------|----------------|
| **64 MB** | 67,108,864 | 24 bloques | 31.89 s | 17.07 s |
| **128 MB** | 134,217,728 | 12 bloques | 39.29 s | 16.01 s |
| **256 MB** | 268,435,456 | 6 bloques | 32.89 s | 16.71 s |

### Fórmula de Bloques
```
Número de bloques = ceil(Tamaño archivo / Block size)

Para archivo de 1.5 GB (1,610,612,736 bytes):
- 64 MB:  1,610,612,736 / 67,108,864  = 24 bloques
- 128 MB: 1,610,612,736 / 134,217,728 = 12 bloques
- 256 MB: 1,610,612,736 / 268,435,456 = 6 bloques
```

---

## PASOS PARA REPLICAR EL EJERCICIO

### PASO 1: Verificar Estado del Cluster

```bash
# Verificar DataNodes activos (debe mostrar 3)
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Live datanodes|Name:'"
```

**Resultado esperado:**
```
Live datanodes (3):
Name: 172.23.0.2:9866 (hadoop-master)
Name: 172.23.0.3:9866 (hadoop-worker2)
Name: 172.23.0.4:9866 (hadoop-worker1)
```

### PASO 2: Limpiar y Crear Directorio de Ejercicio

```bash
# Eliminar directorio anterior si existe y crear nuevo
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio_blocksize 2>/dev/null; hdfs dfs -mkdir -p /ejercicio_blocksize"
```

### PASO 3: Generar Archivo de Prueba (1.5 GB)

```bash
# Crear archivo de 1.5 GB con datos aleatorios
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/testfile_1.5gb bs=1M count=1536"
```

**Tiempo aproximado:** 18 segundos
**Resultado:** Archivo de 1,610,612,736 bytes (1.5 GB)

### PASO 4: Subir con Block Size 64 MB

```bash
# Subir archivo con block size de 64 MB y replicación 1
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -D dfs.blocksize=67108864 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio_blocksize/archivo_bs64mb"
```

**Resultado obtenido:**
- Tiempo de subida: 31.89 segundos
- Bloques creados: 24

### PASO 5: Subir con Block Size 128 MB

```bash
# Subir archivo con block size de 128 MB y replicación 1
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -D dfs.blocksize=134217728 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio_blocksize/archivo_bs128mb"
```

**Resultado obtenido:**
- Tiempo de subida: 39.29 segundos
- Bloques creados: 12

### PASO 6: Subir con Block Size 256 MB

```bash
# Subir archivo con block size de 256 MB y replicación 1
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -D dfs.blocksize=268435456 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio_blocksize/archivo_bs256mb"
```

**Resultado obtenido:**
- Tiempo de subida: 32.89 segundos
- Bloques creados: 6

### PASO 7: Verificar Bloques de Cada Archivo

```bash
# Ver bloques del archivo 64 MB
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs64mb -files -blocks"

# Ver bloques del archivo 128 MB
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs128mb -files -blocks"

# Ver bloques del archivo 256 MB
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs256mb -files -blocks"
```

### PASO 8: Ver Ubicación de Bloques por DataNode

```bash
# Ver en qué DataNode está cada bloque
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs64mb -files -blocks -locations"
```

**Ejemplo de salida:**
```
0. blk_1073741825 len=67108864 [DatanodeInfoWithStorage[172.23.0.2:9866,DS-xxx,DISK]]
1. blk_1073741826 len=67108864 [DatanodeInfoWithStorage[172.23.0.2:9866,DS-xxx,DISK]]
...
```

### PASO 9: Medir Tiempos de Lectura

```bash
# Tiempo de lectura - 64 MB blocks (24 bloques)
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio_blocksize/archivo_bs64mb > /dev/null"

# Tiempo de lectura - 128 MB blocks (12 bloques)
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio_blocksize/archivo_bs128mb > /dev/null"

# Tiempo de lectura - 256 MB blocks (6 bloques)
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio_blocksize/archivo_bs256mb > /dev/null"
```

**Resultados obtenidos:**
| Block Size | Bloques | Tiempo Lectura |
|------------|---------|----------------|
| 64 MB | 24 | 17.07 s |
| 128 MB | 12 | 16.01 s |
| 256 MB | 6 | 16.71 s |

### PASO 10: Limpiar Después del Ejercicio

```bash
# Eliminar archivos de HDFS
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio_blocksize"

# Eliminar archivo local de prueba
docker exec -u hadoop hadoop-master bash -c "rm /tmp/testfile_1.5gb"
```

---

## ANÁLISIS DE RESULTADOS

### 1. Relación Block Size vs Número de Bloques

**Observación:** A mayor block size, menor número de bloques.

```
Block Size ↑  →  Número de Bloques ↓
64 MB  → 24 bloques
128 MB → 12 bloques (mitad)
256 MB → 6 bloques (cuarta parte)
```

**Explicación:** El archivo se divide en chunks del tamaño especificado. Un block size mayor significa menos divisiones.

### 2. Tiempos de Lectura

**Observación:** Los tiempos de lectura son muy similares (~16-17 segundos).

| Block Size | Tiempo | Diferencia vs 128 MB |
|------------|--------|----------------------|
| 64 MB | 17.07 s | +1.06 s (+6.6%) |
| 128 MB | 16.01 s | 0 (base) |
| 256 MB | 16.71 s | +0.70 s (+4.4%) |

**Explicación:**
- La cantidad de datos leídos es idéntica (1.5 GB)
- El cuello de botella es el throughput de I/O, no el número de bloques
- El overhead de abrir múltiples bloques es despreciable
- La diferencia del 6.6% con 64 MB puede deberse a más operaciones de seek

### 3. Distribución de Bloques

**Estado después del ejercicio:**
| DataNode | Bloques | Espacio Usado |
|----------|---------|---------------|
| hadoop-master (172.23.0.2) | 42 | 4.55 GB |
| hadoop-worker1 (172.23.0.4) | 0 | 28 KB |
| hadoop-worker2 (172.23.0.3) | 0 | 28 KB |

**Explicación:** Con replicación = 1, todos los bloques se escriben en el DataNode donde se ejecuta el cliente (hadoop-master). Esto es comportamiento esperado de HDFS para minimizar tráfico de red.

### 4. Implicaciones Prácticas

**Block size pequeño (64 MB):**
- Más metadatos en NameNode
- Mejor para archivos pequeños
- Más paralelismo en MapReduce (más tareas)
- Mayor overhead de gestión

**Block size grande (256 MB):**
- Menos metadatos en NameNode
- Mejor para archivos muy grandes
- Menos paralelismo en MapReduce (menos tareas)
- Menor overhead de gestión

---

## COMANDOS ÚTILES ADICIONALES

### Ver Configuración Actual de Block Size
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs getconf -confKey dfs.blocksize"
```

### Ver Replicación de un Archivo
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -stat %r /ejercicio_blocksize/archivo_bs64mb"
```

### Ver Tamaño de Bloque de un Archivo Específico
```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -stat %o /ejercicio_blocksize/archivo_bs64mb"
```

### Contar Bloques por DataNode
```bash
# Bloques en master
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c '172.23.0.2'"

# Bloques en worker1
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c '172.23.0.4'"

# Bloques en worker2
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c '172.23.0.3'"
```

---

## TABLA DE CONVERSIÓN DE BLOCK SIZES

| Tamaño | Bytes | Valor para -D dfs.blocksize |
|--------|-------|----------------------------|
| 32 MB | 33,554,432 | `-D dfs.blocksize=33554432` |
| 64 MB | 67,108,864 | `-D dfs.blocksize=67108864` |
| 128 MB | 134,217,728 | `-D dfs.blocksize=134217728` |
| 256 MB | 268,435,456 | `-D dfs.blocksize=268435456` |
| 512 MB | 536,870,912 | `-D dfs.blocksize=536870912` |
| 1 GB | 1,073,741,824 | `-D dfs.blocksize=1073741824` |

---

## VERIFICACIÓN DE QUE BLOCK SIZE NO AFECTA GLOBALMENTE

```bash
# Verificar que el block size por defecto sigue siendo 128 MB
docker exec -u hadoop hadoop-master bash -c "hdfs getconf -confKey dfs.blocksize"
# Resultado: 134217728 (128 MB)

# Subir archivo sin especificar block size
docker exec -u hadoop hadoop-master bash -c "echo 'test' > /tmp/default_test.txt && hdfs dfs -put /tmp/default_test.txt /default_test.txt"

# Verificar que usa block size por defecto
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /default_test.txt -files -blocks"
```

**Conclusión:** El parámetro `-D dfs.blocksize=X` solo afecta al archivo específico que se está subiendo, NO cambia la configuración global del cluster.

---

## SCRIPT COMPLETO PARA REPLICAR

```bash
#!/bin/bash
# Script completo para ejercicio de Block Size

echo "=== EJERCICIO BLOCK SIZE EN HDFS ==="
echo ""

# 1. Verificar cluster
echo "1. Verificando cluster..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Live datanodes'"

# 2. Limpiar y crear directorio
echo "2. Creando directorio de ejercicio..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio_blocksize 2>/dev/null; hdfs dfs -mkdir -p /ejercicio_blocksize"

# 3. Generar archivo de prueba
echo "3. Generando archivo de 1.5 GB..."
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/testfile_1.5gb bs=1M count=1536 2>/dev/null"

# 4. Subir con 64 MB
echo "4. Subiendo con block size 64 MB..."
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -D dfs.blocksize=67108864 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio_blocksize/archivo_bs64mb"

# 5. Subir con 128 MB
echo "5. Subiendo con block size 128 MB..."
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -D dfs.blocksize=134217728 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio_blocksize/archivo_bs128mb"

# 6. Subir con 256 MB
echo "6. Subiendo con block size 256 MB..."
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -D dfs.blocksize=268435456 -D dfs.replication=1 -put /tmp/testfile_1.5gb /ejercicio_blocksize/archivo_bs256mb"

# 7. Verificar bloques
echo "7. Verificando bloques creados..."
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs64mb -files -blocks | grep 'Total blocks'"
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs128mb -files -blocks | grep 'Total blocks'"
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_blocksize/archivo_bs256mb -files -blocks | grep 'Total blocks'"

# 8. Medir tiempos de lectura
echo "8. Midiendo tiempos de lectura..."
echo "64 MB blocks:"
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio_blocksize/archivo_bs64mb > /dev/null"
echo "128 MB blocks:"
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio_blocksize/archivo_bs128mb > /dev/null"
echo "256 MB blocks:"
docker exec -u hadoop hadoop-master bash -c "time hdfs dfs -cat /ejercicio_blocksize/archivo_bs256mb > /dev/null"

echo ""
echo "=== EJERCICIO COMPLETADO ==="
```

---

**Ejercicio ejecutado exitosamente el 16 de enero de 2026**
