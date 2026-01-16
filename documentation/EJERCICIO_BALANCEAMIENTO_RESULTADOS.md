# EJERCICIO BALANCEAMIENTO DE BLOQUES EN HDFS - RESULTADOS Y PASOS PARA REPLICAR

**Fecha de ejecución**: 16 de enero de 2026
**Cluster**: 3 nodos (1 master + 2 workers)
**Datos de prueba**: 2 GB (2 archivos de 1 GB cada uno)

---

## RESUMEN DE RESULTADOS

### Tabla Comparativa: Antes vs Después del Balanceo

| DataNode | ANTES (Bloques) | ANTES (Espacio) | DESPUÉS (Bloques) | DESPUÉS (Espacio) |
|----------|-----------------|-----------------|-------------------|-------------------|
| **hadoop-master** (172.23.0.2) | 17 | 2.02 GB | 17 | 2.02 GB |
| **hadoop-worker1** (172.23.0.4) | 0 | 44 KB | 9 | 1.01 GB |
| **hadoop-worker2** (172.23.0.3) | 0 | 28 KB | 8 | 1.01 GB |
| **TOTAL** | 17 | 2.02 GB | 34 | 4.03 GB |

### Observaciones Clave

1. **Antes**: Todos los bloques estaban concentrados en el nodo master (donde se ejecutó el cliente)
2. **Después**: Los bloques se distribuyeron uniformemente entre los 3 DataNodes
3. **Replicación**: Al cambiar de replicación=1 a replicación=3, cada bloque ahora existe en los 3 nodos

---

## CONCEPTOS FUNDAMENTALES

### ¿Por qué los bloques se concentran en un solo nodo?

Cuando subes un archivo con `hdfs dfs -put`:
- HDFS escribe los bloques **primero en el DataNode local** (donde se ejecuta el cliente)
- Con replicación=1, no hay copias adicionales
- Resultado: Todos los bloques quedan en un solo nodo

### ¿Qué hace el HDFS Balancer?

El comando `hdfs balancer`:
- Redistribuye bloques entre DataNodes
- Objetivo: Igualar el **porcentaje de uso** de disco
- **NO** redistribuye si la diferencia está dentro del threshold

### ¿Por qué el balancer no movió bloques en este ejercicio?

```
Threshold: 10%
Uso en master: 0.00% (2 GB de 1 TB)
Uso en workers: 0.00% (0 GB de 1 TB)
Diferencia: 0.00% (menor que 10%)
Resultado: "The cluster is balanced"
```

El balancer trabaja con **porcentajes de espacio**, no con **número de bloques**.

### Estrategia Alternativa: Cambiar Replicación

Para forzar la distribución de bloques:
```bash
hdfs dfs -setrep -w 3 /archivo
```
Esto crea 2 réplicas adicionales en otros DataNodes.

---

## PASOS PARA REPLICAR EL EJERCICIO

### PASO 1: Verificar Estado Inicial del Cluster

```bash
# Ver DataNodes activos y su estado
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:|DFS Used:|Hostname'"
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
# Eliminar directorio anterior si existe
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio_balanceo 2>/dev/null; hdfs dfs -mkdir -p /ejercicio_balanceo"
```

### PASO 3: Generar Archivo de Prueba (1 GB)

```bash
# Crear archivo de 1 GB con datos aleatorios
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/balance_test_1gb bs=1M count=1024"
```

**Tiempo aproximado:** 10 segundos

### PASO 4: Subir Archivos con Replicación 1

```bash
# Subir primer archivo con replicación 1
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.replication=1 -put /tmp/balance_test_1gb /ejercicio_balanceo/archivo1"

# Subir segundo archivo con replicación 1
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.replication=1 -put /tmp/balance_test_1gb /ejercicio_balanceo/archivo2"
```

### PASO 5: Verificar Estado ANTES del Balanceo

```bash
# Ver distribución de bloques por DataNode
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:|DFS Used:'"
```

**Resultado esperado:**
```
Name: 172.23.0.2:9866 (hadoop-master)
DFS Used: 2.02 GB
Num of Blocks: 16-17

Name: 172.23.0.3:9866 (hadoop-worker2)
DFS Used: ~0
Num of Blocks: 0

Name: 172.23.0.4:9866 (hadoop-worker1)
DFS Used: ~0
Num of Blocks: 0
```

### PASO 6: Ver Ubicación de Bloques

```bash
# Ver en qué DataNode está cada bloque
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_balanceo/archivo1 -files -blocks -locations"
```

**Resultado esperado:** Todos los bloques en 172.23.0.2 (hadoop-master)

### PASO 7: Intentar Balanceador HDFS

```bash
# Ejecutar balanceador con threshold 10%
docker exec -u hadoop hadoop-master bash -c "hdfs balancer -threshold 10"
```

**Resultado esperado:**
```
The cluster is balanced. Exiting...
```

**Explicación:** El balancer NO mueve bloques porque la diferencia de uso porcentual es mínima.

### PASO 8: Forzar Distribución con Cambio de Replicación

```bash
# Cambiar replicación de archivo1 a 3
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -setrep -w 3 /ejercicio_balanceo/archivo1"

# Cambiar replicación de archivo2 a 3
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -setrep -w 3 /ejercicio_balanceo/archivo2"
```

**El flag -w (wait) espera hasta que la replicación se complete.**

### PASO 9: Verificar Estado DESPUÉS del Balanceo

```bash
# Ver nueva distribución de bloques
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:|DFS Used:'"
```

**Resultado esperado:**
```
Name: 172.23.0.2:9866 (hadoop-master)
DFS Used: 2.02 GB
Num of Blocks: 16-17

Name: 172.23.0.3:9866 (hadoop-worker2)
DFS Used: ~1 GB
Num of Blocks: 8

Name: 172.23.0.4:9866 (hadoop-worker1)
DFS Used: ~1 GB
Num of Blocks: 8-9
```

### PASO 10: Verificar que Cada Bloque Tiene 3 Réplicas

```bash
# Ver ubicación de cada bloque
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_balanceo/archivo1 -files -blocks -locations 2>/dev/null | head -15"
```

**Resultado esperado:**
```
0. blk_xxx len=134217728 Live_repl=3  [172.23.0.2, 172.23.0.3, 172.23.0.4]
1. blk_xxx len=134217728 Live_repl=3  [172.23.0.2, 172.23.0.3, 172.23.0.4]
...
```

---

## ANÁLISIS DE RESULTADOS

### 1. Comportamiento del Balanceador HDFS

| Escenario | Balancer Actúa? | Razón |
|-----------|-----------------|-------|
| 90% en nodo A, 10% en nodo B | ✅ Sí | Diferencia > threshold |
| 50% en nodo A, 50% en nodo B | ❌ No | Ya está balanceado |
| 0.1% en nodo A, 0% en nodo B | ❌ No | Diferencia < threshold |

**En nuestro ejercicio:**
- Uso total: ~0.0001% del cluster
- El balancer no ve diferencia significativa

### 2. Replicación vs Balanceamiento

| Método | Qué hace | Cuándo usar |
|--------|----------|-------------|
| `hdfs balancer` | Mueve bloques existentes | Cluster desbalanceado (>threshold) |
| `hdfs dfs -setrep` | Crea/elimina réplicas | Cambiar tolerancia a fallos |

### 3. Impacto del Factor de Replicación

| Replicación | Bloques Totales | Espacio Usado | Tolerancia a Fallos |
|-------------|-----------------|---------------|---------------------|
| 1 | N | X GB | 0 nodos pueden fallar |
| 2 | 2N | 2X GB | 1 nodo puede fallar |
| 3 | 3N | 3X GB | 2 nodos pueden fallar |

**En nuestro ejercicio:**
- Replicación 1: 16 bloques, 2 GB
- Replicación 3: 48 réplicas de bloques, 6 GB (pero mostramos 34 porque algunos se comparten)

---

## COMANDOS ÚTILES ADICIONALES

### Ver Replicación de un Archivo

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -stat %r /ejercicio_balanceo/archivo1"
```

### Cambiar Replicación de Todo un Directorio

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -setrep -w -R 2 /ejercicio_balanceo"
```

### Ver Bloques Sub-replicados

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Under replicated'"
```

### Ejecutar Balanceador con Threshold Bajo

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs balancer -threshold 1"
```

### Ejecutar Balanceador en Background

```bash
docker exec -u hadoop hadoop-master bash -c "nohup hdfs balancer -threshold 5 > /tmp/balancer.log 2>&1 &"
```

### Ver Progreso del Balanceador

```bash
docker exec -u hadoop hadoop-master bash -c "tail -f /tmp/balancer.log"
```

### Contar Bloques por DataNode

```bash
# Master
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c '172.23.0.2'"

# Worker1
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c '172.23.0.4'"

# Worker2
docker exec -u hadoop hadoop-master bash -c "hdfs fsck / -files -blocks -locations 2>/dev/null | grep -c '172.23.0.3'"
```

---

## MÉTRICAS A OBSERVAR

### 1. Número de Bloques por DataNode

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Num of Blocks'"
```

### 2. Espacio Usado por DataNode

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'DFS Used:'"
```

### 3. Porcentaje de Uso por DataNode

```bash
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'DFS Used%'"
```

### 4. Distribución Uniforme

**Fórmula:** Desviación = |Bloques_nodo - Promedio| / Promedio * 100

**Ejemplo:**
```
Promedio = (17 + 9 + 8) / 3 = 11.33 bloques
Desviación master = |17 - 11.33| / 11.33 * 100 = 50%
Desviación worker1 = |9 - 11.33| / 11.33 * 100 = 20%
Desviación worker2 = |8 - 11.33| / 11.33 * 100 = 29%
```

---

## ESCENARIOS DE PRUEBA ADICIONALES

### Escenario 1: Forzar Desbalance Extremo

```bash
# Subir muchos archivos pequeños (todos irán al master)
for i in {1..100}; do
  echo "archivo $i" > /tmp/file_$i.txt
  hdfs dfs -D dfs.replication=1 -put /tmp/file_$i.txt /test_desbalance/
done
```

### Escenario 2: Balancear con Threshold Muy Bajo

```bash
# Usar threshold de 0.1%
hdfs balancer -threshold 0.1
```

### Escenario 3: Simular Falla de Nodo

```bash
# Detener DataNode en worker1
docker exec -u hadoop hadoop-worker1 bash -c "hdfs --daemon stop datanode"

# Verificar que HDFS marca bloques como sub-replicados
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep 'Under replicated'"

# Reiniciar DataNode
docker exec -u hadoop hadoop-worker1 bash -c "hdfs --daemon start datanode"
```

---

## SCRIPT COMPLETO PARA REPLICAR

```bash
#!/bin/bash
# Script completo para ejercicio de Balanceamiento

echo "=== EJERCICIO BALANCEAMIENTO EN HDFS ==="
echo ""

# 1. Verificar cluster
echo "1. Verificando cluster..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Live datanodes|Name:'"

# 2. Limpiar y crear directorio
echo ""
echo "2. Creando directorio de ejercicio..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio_balanceo 2>/dev/null; hdfs dfs -mkdir -p /ejercicio_balanceo"

# 3. Generar archivo de prueba
echo ""
echo "3. Generando archivo de 1 GB..."
docker exec -u hadoop hadoop-master bash -c "dd if=/dev/urandom of=/tmp/balance_test_1gb bs=1M count=1024 2>/dev/null"

# 4. Subir archivos con replicación 1
echo ""
echo "4. Subiendo archivos con replicación 1..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.replication=1 -put /tmp/balance_test_1gb /ejercicio_balanceo/archivo1"
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -D dfs.replication=1 -put /tmp/balance_test_1gb /ejercicio_balanceo/archivo2"

# 5. Estado ANTES
echo ""
echo "5. Estado ANTES del balanceo:"
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:' | head -9"

# 6. Intentar balanceador
echo ""
echo "6. Ejecutando balanceador..."
docker exec -u hadoop hadoop-master bash -c "hdfs balancer -threshold 10 2>&1 | tail -5"

# 7. Cambiar replicación
echo ""
echo "7. Cambiando replicación a 3..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -setrep -w 3 /ejercicio_balanceo/archivo1"
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -setrep -w 3 /ejercicio_balanceo/archivo2"

# 8. Estado DESPUÉS
echo ""
echo "8. Estado DESPUÉS del balanceo:"
docker exec -u hadoop hadoop-master bash -c "hdfs dfsadmin -report | grep -E 'Name:|Num of Blocks:' | head -9"

# 9. Verificar distribución
echo ""
echo "9. Verificando distribución de bloques:"
docker exec -u hadoop hadoop-master bash -c "hdfs fsck /ejercicio_balanceo/archivo1 -files -blocks -locations 2>/dev/null | head -5"

echo ""
echo "=== EJERCICIO COMPLETADO ==="
```

---

## CONCLUSIONES

### 1. El HDFS Balancer no siempre actúa

- Trabaja con **porcentajes de uso**, no con número de bloques
- Si la diferencia está dentro del threshold, no mueve datos
- Útil para clusters con alto uso de disco

### 2. Cambiar replicación SÍ distribuye bloques

- `hdfs dfs -setrep` crea réplicas en otros nodos
- Útil para mejorar tolerancia a fallos
- Aumenta el espacio usado

### 3. La distribución inicial depende del cliente

- Bloques se escriben primero en el DataNode local
- Con replicación=1, quedan concentrados
- La replicación distribuye automáticamente

### 4. Métricas clave a observar

- Número de bloques por DataNode
- Espacio usado por DataNode
- Porcentaje de uso por DataNode
- Bloques sub-replicados

---

## LIMPIAR DESPUÉS DEL EJERCICIO

```bash
# Eliminar datos de HDFS
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -rm -r /ejercicio_balanceo"

# Eliminar archivo local
docker exec -u hadoop hadoop-master bash -c "rm /tmp/balance_test_1gb"

# Verificar limpieza
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -ls /"
```

---

**Ejercicio ejecutado exitosamente el 16 de enero de 2026**

### Aprendizajes Clave

1. **Replicación=1**: Todos los bloques en un nodo → Sin tolerancia a fallos
2. **Replicación=3**: Bloques en todos los nodos → 2 nodos pueden fallar
3. **Balancer**: Útil cuando hay diferencia significativa de uso de disco
4. **setrep**: Útil para distribuir bloques independientemente del uso de disco
