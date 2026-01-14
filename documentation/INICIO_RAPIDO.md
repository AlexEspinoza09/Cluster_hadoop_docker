# Guía de Inicio Rápido - Cluster Hadoop

## Comandos Principales

### Iniciar el Cluster Completo (DESDE CERO)

```powershell
# Usa este comando cuando:
# - Acabas de reiniciar tu computadora
# - Hiciste docker-compose down
# - Es la primera vez que usas el cluster

powershell -ExecutionPolicy Bypass -File .\start-full-cluster.ps1
```

Este script hace TODO automáticamente:
1. Levanta los contenedores Docker
2. Configura Hadoop
3. Inicia HDFS
4. Inicia YARN
5. Inicia Job History Server

⏱️ **Tiempo:** ~2 minutos

### Detener el Cluster

```powershell
# Detener solo Hadoop (los contenedores siguen corriendo)
docker exec -u hadoop hadoop-master stop-yarn.sh
docker exec -u hadoop hadoop-master stop-dfs.sh

# Detener y eliminar contenedores completamente
docker-compose down
```

### Reiniciar Solo Hadoop (si los contenedores ya están corriendo)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\configure-and-start-hadoop.ps1
```

## Verificar que Todo Funciona

### 1. Ver Procesos Activos

```powershell
docker exec -u hadoop hadoop-master jps
```

Deberías ver:
- NameNode
- DataNode
- ResourceManager
- NodeManager
- JobHistoryServer

### 2. Ver Nodos YARN

```powershell
docker exec -u hadoop hadoop-master yarn node -list
```

Deberías ver 3 nodos en estado RUNNING.

### 3. Probar Interfaces Web

Abre tu navegador en:
- http://localhost:8088 (ResourceManager)
- http://localhost:9870 (NameNode)
- http://localhost:19888 (Job History)

## Ejecutar una Prueba Rápida

```powershell
# Ejecutar estimación de Pi
docker exec -u hadoop hadoop-master hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 1000

# Ver el resultado en la interfaz web
# Ve a http://localhost:8088 y verás la aplicación ejecutándose
```

## Problemas Comunes

### "No puedo acceder a http://localhost:8088"

**Solución:**
1. Verifica que Hadoop esté corriendo:
   ```powershell
   docker exec -u hadoop hadoop-master jps
   ```
2. Si no ves los procesos, ejecuta:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\configure-and-start-hadoop.ps1
   ```

### "Hice docker-compose down y ahora no funciona"

**Solución:**
```powershell
powershell -ExecutionPolicy Bypass -File .\start-full-cluster.ps1
```

### "Los contenedores están corriendo pero Hadoop no"

**Solución:**
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\configure-and-start-hadoop.ps1
```

## Workflow Típico

### Primera Vez / Después de Reiniciar PC

```powershell
# 1. Iniciar todo
powershell -ExecutionPolicy Bypass -File .\start-full-cluster.ps1

# 2. Verificar que funciona
docker exec -u hadoop hadoop-master jps
docker exec -u hadoop hadoop-master yarn node -list

# 3. Abrir navegador en http://localhost:8088
```

### Trabajo Diario (contenedores ya están corriendo)

```powershell
# Si hiciste docker-compose stop antes
docker-compose start

# Luego iniciar Hadoop
powershell -ExecutionPolicy Bypass -File .\scripts\configure-and-start-hadoop.ps1
```

### Al Terminar

```powershell
# Opción 1: Solo detener Hadoop (mantiene contenedores)
docker exec -u hadoop hadoop-master stop-yarn.sh
docker exec -u hadoop hadoop-master stop-dfs.sh

# Opción 2: Detener todo
docker-compose down
```

## Monitoreo en Tiempo Real

```powershell
# Ver estado del cluster actualizándose cada 5 segundos
powershell -ExecutionPolicy Bypass -File .\scripts\monitor-cluster.ps1
```

## Próximos Pasos

- Lee `GUIA_MONITOREO_RENDIMIENTO.md` para aprender a monitorear rendimiento
- Lee `COMANDOS_RAPIDOS.md` para referencia de comandos
- Ejecuta pruebas de benchmark en `scripts/test-hadoop-performance.sh`
