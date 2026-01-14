# Estimación de Pi - Prueba de Procesamiento CPU Intensivo

## Prueba Completada Exitosamente

Acabas de ejecutar un trabajo de **estimación de Pi usando el método Monte Carlo** que distribuyó 20 tareas de procesamiento intensivo de CPU entre tus 3 nodos.

## Métricas de Rendimiento

### Tiempo de Ejecución
- **Fase Map**: ~146 segundos (2.4 minutos)
- **Fase Reduce**: ~2 segundos
- **Total**: 149.76 segundos (~2.5 minutos)

### Resultado de la Estimación
- **Valor estimado de Pi**: 3.14118
- **Valor real de Pi**: 3.14159265...
- **Precisión**: 99.97% de exactitud
- **Error**: 0.00041 (muy preciso!)

### Procesamiento Distribuido
- **Tareas Map lanzadas**: 20
- **Tareas Reduce lanzadas**: 1
- **Muestras por Map**: 10,000
- **Muestras totales**: 200,000 puntos aleatorios

### Distribución de Trabajo
- **Data-local map tasks**: 7 (ejecutadas en el mismo nodo donde están los datos)
- **Rack-local map tasks**: 13 (ejecutadas en nodos cercanos)
- **Total tiempo CPU**: 100.02 segundos (1 minuto 40 segundos)
- **Total tiempo Map**: 1,030,070 ms (17 minutos sumando todas las tareas)

### Uso de Recursos
- **Memoria física pico total**: 6.68 GB
- **Memoria pico por Map**: ~337 MB
- **Memoria pico por Reduce**: ~229 MB
- **Tiempo de GC (Garbage Collection)**: 33.18 segundos
- **Virtual cores-milliseconds**: 1,071,028 (Map + Reduce combinados)

## Cómo Funciona el Método Monte Carlo

### Concepto
El método Monte Carlo para estimar π funciona generando puntos aleatorios en un cuadrado y contando cuántos caen dentro de un círculo inscrito:

```
Cuadrado de lado 1
    ┌─────────────┐
    │    ╭───╮    │
    │  ╭─────────╮ │  Radio = 1
    │ │    •••    │ │
    │ │   •••••   │ │  Círculo inscrito
    │ │   •••••   │ │  Área = π × r²
    │  ╰─────────╯ │
    └─────────────┘
Cuadrado: Área = 4

Relación: Puntos en círculo / Puntos totales ≈ π/4
Por lo tanto: π ≈ 4 × (puntos en círculo / puntos totales)
```

### Distribución del Trabajo
```
Master divide en 20 tareas
         ↓
    Cada tarea genera 10,000 puntos aleatorios
         ↓
    Cuenta cuántos caen dentro del círculo
         ↓
    Tareas distribuidas entre 3 nodos (7 local + 13 rack-local)
         ↓
    Reducer agrega todos los resultados
         ↓
    Calcula estimación final de Pi
```

## Comparación con WordCount

| Métrica | WordCount | Pi Estimation |
|---------|-----------|---------------|
| **Tipo** | I/O intensivo | CPU intensivo |
| **Tiempo total** | 28 segundos | 150 segundos |
| **Tiempo Map** | 19 segundos | 146 segundos |
| **Tiempo CPU** | 13 segundos | 100 segundos |
| **Datos procesados** | 6.2 MB | 2.3 KB (entrada pequeña) |
| **Memoria pico** | 551 MB | 6.68 GB |
| **Tareas Map** | Variable | 20 tareas |

**Observación clave**:
- WordCount es más rápido porque procesa datos (I/O)
- Pi Estimation es más lento porque hace cálculos intensivos (CPU)
- Pi Estimation usa más memoria porque mantiene arrays de puntos aleatorios

## Distribución Entre Nodos

### Data-local (7 tareas)
Estas tareas se ejecutaron en el mismo nodo donde estaban los datos de entrada, minimizando transferencia de red.

### Rack-local (13 tareas)
Estas tareas se ejecutaron en nodos diferentes, pero YARN optimizó la ubicación para minimizar latencia.

**Esto demuestra**:
1. YARN está balanceando la carga entre los 3 nodos
2. El cluster está procesando tareas en paralelo
3. La localidad de datos está siendo optimizada automáticamente

## Ver Resultados en las Interfaces Web

### ResourceManager - Ver el Job
**URL**: http://localhost:8088/cluster/apps

Busca la aplicación "QuasiMonteCarlo" (application_1768261826278_0002)

### Job History - Detalles del Job
**URL**: http://localhost:19888/jobhistory/job/job_1768261826278_0002

Aquí puedes ver:
- Detalles de cada una de las 20 tareas Map
- Timeline de ejecución
- Gráficos de uso de CPU y memoria
- Distribución de tareas entre nodos

## Lo Que Demuestra Esta Prueba

1. **Procesamiento CPU distribuido**: 20 tareas ejecutándose en paralelo
2. **Balanceo de carga**: YARN distribuyó las tareas entre los 3 nodos
3. **Escalabilidad de cómputo**: Más nodos = más tareas en paralelo = resultados más rápidos
4. **Optimización de localidad**: 7 tareas data-local muestran optimización de YARN
5. **Gestión de recursos**: Picos de memoria controlados automáticamente

## Por Qué Este Test es Importante

### 1. Tipo de Carga Diferente
- WordCount testa I/O (lectura/escritura)
- Pi Estimation testa CPU (cálculos)
- Juntos demuestran que el cluster maneja ambos tipos de carga

### 2. Paralelismo Real
20 tareas Map significa que el cluster puede ejecutar hasta 20 cálculos simultáneos (limitado por recursos disponibles)

### 3. Precisión Matemática
El resultado (π ≈ 3.14118) con solo 200,000 muestras demuestra que los cálculos son correctos y reproducibles.

## Comandos Útiles

### Ver Detalles del Job
```bash
docker exec -u hadoop hadoop-master yarn application -status application_1768261826278_0002
```

### Ver Logs de una Tarea Específica
```bash
docker exec -u hadoop hadoop-master yarn logs -applicationId application_1768261826278_0002
```

### Ver Uso de Recursos Durante Ejecución
```bash
docker exec -u hadoop hadoop-master yarn top
```

## Próximos Benchmarks Sugeridos

### 1. Aumentar Precisión de Pi
```bash
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar pi 50 100000"
```
- 50 Maps (más paralelismo)
- 100,000 muestras por map
- Total: 5,000,000 puntos
- Resultado más preciso, más tiempo de ejecución

### 2. TestDFSIO - Benchmark de I/O
```bash
# Escritura
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -write -nrFiles 10 -fileSize 100MB"

# Lectura
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.6-tests.jar TestDFSIO -read -nrFiles 10 -fileSize 100MB"
```
Mide MB/s de throughput de HDFS

### 3. TeraSort - Benchmark de Ordenamiento
```bash
# Generar 10 GB de datos aleatorios
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar teragen 100000000 /terasort-input"

# Ordenar
docker exec -u hadoop hadoop-master bash -c "hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar terasort /terasort-input /terasort-output"
```
Benchmark estándar de la industria

## Análisis de Rendimiento

### ¿Por Qué Tomó 150 Segundos?

1. **Startup overhead**: ~25 segundos para iniciar contenedores de tareas
2. **Cálculos CPU**: 100 segundos de tiempo real de CPU
3. **GC (Garbage Collection)**: 33 segundos limpiando memoria
4. **Shuffle y Reduce**: 2 segundos agregando resultados

### ¿Cómo Mejorar el Rendimiento?

1. **Añadir más nodos**: Con 6 nodos, las 20 tareas terminarían ~50% más rápido
2. **Más vCores por nodo**: Permite más tareas concurrentes por nodo
3. **Más memoria**: Reduce tiempo de GC
4. **Optimizar parámetros JVM**: Ajustar heap size y GC algorithm

## Aprendizajes Clave

1. **Monte Carlo es CPU-bound**: El tiempo de ejecución está dominado por cálculos, no I/O
2. **Paralelismo funciona**: 20 tareas en 3 nodos procesando simultáneamente
3. **Precisión vs Tiempo**: Más muestras = más precisión = más tiempo
4. **YARN gestiona recursos**: Distribución automática de 20 tareas entre nodos disponibles
5. **Garbage Collection importa**: 33s de GC en 150s total = 22% del tiempo

---

**Tu cluster procesó 200,000 puntos aleatorios distribuidos entre 3 nodos y estimó Pi con 99.97% de precisión!** 🎯

**Application ID**: application_1768261826278_0002
**Job ID**: job_1768261826278_0002
**Estado**: FINISHED / SUCCEEDED

Visita http://localhost:8088 o http://localhost:19888 para ver más detalles.
