#!/bin/bash

echo "======================================"
echo "Configurando Hadoop en el Cluster"
echo "======================================"
echo ""

HADOOP_CONF_DIR="/opt/hadoop/etc/hadoop"
CONFIG_SOURCE="/tmp/hadoop-config"

# Lista de contenedores
NODES=("hadoop-master" "hadoop-worker1" "hadoop-worker2")

echo "Distribuyendo archivos de configuración a todos los nodos..."
echo ""

for node in "${NODES[@]}"; do
    echo "Configurando $node..."

    # Copiar archivos de configuración
    docker exec $node bash -c "cp $CONFIG_SOURCE/core-site.xml $HADOOP_CONF_DIR/"
    docker exec $node bash -c "cp $CONFIG_SOURCE/hdfs-site.xml $HADOOP_CONF_DIR/"
    docker exec $node bash -c "cp $CONFIG_SOURCE/yarn-site.xml $HADOOP_CONF_DIR/"
    docker exec $node bash -c "cp $CONFIG_SOURCE/mapred-site.xml $HADOOP_CONF_DIR/"
    docker exec $node bash -c "cp $CONFIG_SOURCE/workers $HADOOP_CONF_DIR/"

    # Dar permisos al usuario hadoop
    docker exec $node bash -c "chown -R hadoop:hadoop $HADOOP_CONF_DIR"

    echo "  ✓ $node configurado"
done

echo ""
echo "======================================"
echo "Configuración distribuida exitosamente!"
echo "======================================"
echo ""
echo "Próximo paso: Formatear el NameNode"
echo "  Ejecuta: bash scripts/format-namenode.sh"
