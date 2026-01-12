# Cluster Hadoop con Docker

Este proyecto configura un cluster de Hadoop distribuido con 3 nodos usando Docker.

## Arquitectura del Cluster

- **hadoop-master**: NameNode + ResourceManager + DataNode
- **hadoop-worker1**: DataNode + NodeManager + Secondary NameNode
- **hadoop-worker2**: DataNode + NodeManager

## Tecnologías

- Hadoop 3.3.6
- Java 8
- Ubuntu 22.04
- Docker & Docker Compose

## Estructura del Proyecto

```
Proyecto_Hadoop/
├── Dockerfile              # Imagen base para los nodos
├── docker-compose.yml      # Orquestación de contenedores
├── hadoop-config/          # Archivos de configuración de Hadoop
├── scripts/                # Scripts de utilidad
│   ├── start-cluster.sh    # Iniciar el cluster
│   └── stop-cluster.sh     # Detener el cluster
└── data/                   # Datos persistentes
    ├── namenode/
    ├── datanode1/
    ├── datanode2/
    └── datanode3/
```

## Inicio Rápido

### 1. Construir y levantar los contenedores

```bash
docker-compose up -d --build
```

O usando el script:

```bash
bash scripts/start-cluster.sh
```

### 2. Verificar que los contenedores están corriendo

```bash
docker-compose ps
```

### 3. Acceder al nodo master

```bash
docker exec -it hadoop-master bash
```

## Interfaces Web

Una vez configurado Hadoop:

- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088
- **Job History Server**: http://localhost:19888

## Detener el Cluster

```bash
docker-compose down
```

O usando el script:

```bash
bash scripts/stop-cluster.sh
```

## Próximos Pasos

Después de levantar los contenedores, necesitarás configurar Hadoop:

1. Configurar archivos XML de Hadoop (core-site.xml, hdfs-site.xml, yarn-site.xml, mapred-site.xml)
2. Formatear el NameNode
3. Iniciar los servicios de Hadoop
4. Verificar la comunicación entre nodos

## Comandos Útiles

```bash
# Ver logs de un contenedor
docker logs hadoop-master

# Ejecutar comandos en el master
docker exec -it hadoop-master hdfs dfs -ls /

# Reiniciar un contenedor
docker-compose restart hadoop-master

# Ver uso de recursos
docker stats
```
