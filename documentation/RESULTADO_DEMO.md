# Resultado de la Demostración del Cluster Hadoop

## ✅ Prueba Completada Exitosamente

Acabas de ejecutar un trabajo de **MapReduce WordCount** que procesó 100,000 líneas de texto distribuido entre tus 3 nodos.

## 📊 Métricas de Rendimiento

### Tiempo de Ejecución
- **Fase Map**: 19.2 segundos
- **Fase Reduce**: 9.2 segundos
- **Total**: ~28 segundos

### Procesamiento de Datos
- **Líneas procesadas**: 100,000
- **Datos leídos desde HDFS**: 6.2 MB
- **Datos escritos**: 833 bytes
- **Palabras únicas encontradas**: 60

### Uso de Recursos
- **CPU total**: 13.1 segundos
- **Memoria pico**: ~551 MB
- **Nodos participantes**: 3 (hadoop-master, hadoop-worker1, hadoop-worker2)

## 🏆 Top 15 Palabras Más Frecuentes

| Palabra | Frecuencia |
|---------|-----------|
| de | 50,000 |
| datos | 40,000 |
| procesamiento | 30,000 |
| nodos | 30,000 |
| los | 30,000 |
| entre | 30,000 |
| en | 30,000 |
| tareas | 20,000 |
| paralelo | 20,000 |
| para | 20,000 |
| la | 20,000 |
| el | 20,000 |
| del | 20,000 |
| cluster | 20,000 |
| Los | 20,000 |

## 🌐 Ver Resultados en las Interfaces Web

### 1. ResourceManager - Ver el Job Ejecutado
**URL**: http://localhost:8088/cluster/apps

Aquí puedes ver:
- Lista de todas las aplicaciones ejecutadas
- Click en "word count" para ver detalles del job
- Métricas de tiempo, memoria y CPU
- Distribución del trabajo entre nodos

### 2. Job History - Métricas Detalladas
**URL**: http://localhost:19888/jobhistory

Verás:
- Historial completo del job
- Detalles de cada tarea Map y Reduce
- Gráficos de rendimiento
- Logs de ejecución

### 3. NameNode - Explorar Archivos HDFS
**URL**: http://localhost:9870/explorer.html#/demo

Puedes:
- Navegar por el sistema de archivos HDFS
- Ver el archivo de entrada: `/demo/input/bigdataset.txt`
- Ver los resultados: `/demo/output/part-r-00000`
- Descargar archivos

## 🔍 Cómo Funciona el Procesamiento Distribuido

### Paso 1: División de Datos (Map Phase)
```
Archivo grande (6.2 MB, 100,000 líneas)
         ↓
    Dividido en bloques
         ↓
  Procesado en paralelo por los 3 nodos
         ↓
    Cada nodo cuenta palabras localmente
```

### Paso 2: Agregación (Shuffle & Sort)
```
Resultados de cada nodo
         ↓
    Transferidos y ordenados
         ↓
    Agrupados por palabra
```

### Paso 3: Reducción (Reduce Phase)
```
Palabras agrupadas
         ↓
    Conteo final por palabra
         ↓
    Resultado: 60 palabras únicas con sus frecuencias
```

## 🎯 Lo Que Demuestra Esta Prueba

1. **Comunicación entre Nodos**: Los 3 nodos (master + 2 workers) se comunicaron exitosamente
2. **Procesamiento Paralelo**: Las tareas Map se distribuyeron entre los nodos disponibles
3. **HDFS Funcional**: Los datos se almacenaron y leyeron correctamente
4. **YARN Operativo**: ResourceManager coordinó la ejecución exitosamente
5. **MapReduce Completo**: Todo el ciclo Map-Shuffle-Reduce funcionó correctamente

## 🚀 Próximas Pruebas Sugeridas

### Prueba 1: Estimación de Pi (CPU Intensivo)
```bash
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 20 10000
```
**Qué hace**: Usa el método Monte Carlo para estimar Pi. Verás cómo se distribuye el cálculo intensivo.

### Prueba 2: Benchmark de Lectura/Escritura (I/O)
```bash
# Escritura
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -write -nrFiles 10 -fileSize 100MB

# Lectura
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -read -nrFiles 10 -fileSize 100MB
```
**Qué hace**: Mide el rendimiento de I/O del cluster (MB/s).

### Prueba 3: TeraSort (Ordenamiento Masivo)
```bash
# Generar datos
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  teragen 1000000 /terasort-input

# Ordenar
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  terasort /terasort-input /terasort-output

# Validar
docker exec -u hadoop hadoop-master hadoop jar \
  /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  teravalidate /terasort-output /terasort-validate
```
**Qué hace**: Benchmark estándar de Hadoop para medir rendimiento de ordenamiento.

## 📈 Cómo Interpretar los Resultados

### En ResourceManager (http://localhost:8088):
- **State: FINISHED** = Job completado exitosamente
- **Final Status: SUCCEEDED** = Sin errores
- **Progress: 100%** = Todo procesado
- **Elapsed Time** = Duración total del job

### En Job History (http://localhost:19888):
- **Map Tasks** = Número de tareas de procesamiento paralelo
- **Reduce Tasks** = Número de tareas de agregación
- **CPU Time** = Tiempo real de procesamiento
- **Shuffle Time** = Tiempo de transferencia de datos entre nodos

## 💡 Tips para Mejorar el Rendimiento

1. **Más datos = mejor paralelismo**: Archivos pequeños no se benefician mucho del paralelismo
2. **Ajustar memoria**: Si los jobs fallan, aumenta la memoria en `yarn-site.xml`
3. **Balanceo de carga**: YARN distribuye automáticamente el trabajo
4. **Monitoreo**: Usa las interfaces web para identificar cuellos de botella

## 📝 Archivos Creados

Los resultados están en HDFS:
```bash
# Ver resultados
docker exec -u hadoop hadoop-master hdfs dfs -cat /demo/output/part-r-00000

# Listar archivos
docker exec -u hadoop hadoop-master hdfs dfs -ls -R /demo

# Descargar resultados
docker exec -u hadoop hadoop-master hdfs dfs -get /demo/output/part-r-00000 /tmp/resultado.txt
```

## 🎓 Aprendizajes Clave

1. **HDFS**: Almacena datos de forma distribuida y confiable
2. **YARN**: Gestiona recursos y coordina ejecución
3. **MapReduce**: Procesa datos en paralelo de forma eficiente
4. **Comunicación**: Los nodos se coordinan automáticamente
5. **Escalabilidad**: Añadir más nodos mejoraría el rendimiento

---

**¡Tu cluster Hadoop está funcionando perfectamente!** 🎉

Puedes ejecutar más pruebas o desarrollar tus propias aplicaciones MapReduce.
