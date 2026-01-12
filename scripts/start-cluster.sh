#!/bin/bash

echo "======================================"
echo "Iniciando Cluster Hadoop con Docker"
echo "======================================"
echo ""

echo "Construyendo imágenes Docker..."
docker-compose build

echo ""
echo "Levantando contenedores..."
docker-compose up -d

echo ""
echo "Esperando a que los contenedores estén listos..."
sleep 10

echo ""
echo "======================================"
echo "Estado del Cluster:"
echo "======================================"
docker-compose ps

echo ""
echo "======================================"
echo "Cluster levantado exitosamente!"
echo "======================================"
echo ""
echo "URLs de acceso:"
echo "  - NameNode Web UI: http://localhost:9870"
echo "  - ResourceManager Web UI: http://localhost:8088"
echo "  - Job History Server: http://localhost:19888"
echo ""
echo "Para conectarte al nodo master:"
echo "  docker exec -it hadoop-master bash"
echo ""
echo "Para detener el cluster:"
echo "  docker-compose down"
echo ""
