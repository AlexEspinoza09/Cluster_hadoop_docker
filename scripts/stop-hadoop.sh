#!/bin/bash

echo "======================================"
echo "Deteniendo Servicios de Hadoop"
echo "======================================"
echo ""

# Detener Job History Server
echo "Deteniendo Job History Server..."
docker exec -u hadoop hadoop-master bash -c "mapred --daemon stop historyserver"
echo "  ✓ Job History Server detenido"
echo ""

# Detener YARN
echo "Deteniendo YARN..."
docker exec -u hadoop hadoop-master bash -c "stop-yarn.sh"
echo "  ✓ YARN detenido"
echo ""

# Detener HDFS
echo "Deteniendo HDFS..."
docker exec -u hadoop hadoop-master bash -c "stop-dfs.sh"
echo "  ✓ HDFS detenido"
echo ""

echo "======================================"
echo "Hadoop detenido exitosamente!"
echo "======================================"
