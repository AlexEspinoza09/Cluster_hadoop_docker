#!/bin/bash

echo "======================================"
echo "Formateando NameNode"
echo "======================================"
echo ""

echo "ADVERTENCIA: Esto eliminará todos los datos existentes en HDFS!"
echo "Presiona Ctrl+C para cancelar o espera 5 segundos para continuar..."
sleep 5

echo ""
echo "Formateando NameNode en hadoop-master..."

# Formatear el NameNode
docker exec -u hadoop hadoop-master bash -c "hdfs namenode -format -force"

if [ $? -eq 0 ]; then
    echo ""
    echo "======================================"
    echo "NameNode formateado exitosamente!"
    echo "======================================"
    echo ""
    echo "Próximo paso: Iniciar servicios de Hadoop"
    echo "  Ejecuta: bash scripts/start-hadoop.sh"
else
    echo ""
    echo "ERROR: Falló el formateo del NameNode"
    exit 1
fi
