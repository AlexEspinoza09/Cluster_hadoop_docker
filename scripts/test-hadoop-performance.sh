#!/bin/bash

echo "======================================"
echo "PRUEBAS DE RENDIMIENTO HADOOP CLUSTER"
echo "======================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== 1. ESTADO DEL CLUSTER ===${NC}"
echo ""
echo -e "${YELLOW}Nodos YARN activos:${NC}"
yarn node -list
echo ""

echo -e "${YELLOW}Estado de HDFS:${NC}"
hdfs dfsadmin -report | head -20
echo ""

echo -e "${CYAN}=== 2. PRUEBA DE ESCRITURA/LECTURA EN HDFS ===${NC}"
echo ""

# Crear archivo de prueba grande
echo -e "${YELLOW}Creando archivo de prueba de 100MB...${NC}"
dd if=/dev/zero of=/tmp/testfile bs=1M count=100 2>/dev/null
echo "Archivo de prueba creado: 100MB"
echo ""

# Medir tiempo de escritura a HDFS
echo -e "${YELLOW}Midiendo velocidad de escritura a HDFS...${NC}"
START_TIME=$(date +%s)
hdfs dfs -put /tmp/testfile /testfile
END_TIME=$(date +%s)
WRITE_TIME=$((END_TIME - START_TIME))
echo "Tiempo de escritura: ${WRITE_TIME} segundos"
echo ""

# Ver información del archivo en HDFS
echo -e "${YELLOW}Información del archivo en HDFS:${NC}"
hdfs fsck /testfile -files -blocks -locations
echo ""

# Medir tiempo de lectura desde HDFS
echo -e "${YELLOW}Midiendo velocidad de lectura desde HDFS...${NC}"
START_TIME=$(date +%s)
hdfs dfs -get /testfile /tmp/testfile_downloaded
END_TIME=$(date +%s)
READ_TIME=$((END_TIME - START_TIME))
echo "Tiempo de lectura: ${READ_TIME} segundos"
echo ""

echo -e "${CYAN}=== 3. PRUEBA DE MAPREDUCE: WORDCOUNT ===${NC}"
echo ""

# Crear archivo de texto de prueba
echo -e "${YELLOW}Creando archivo de texto de prueba...${NC}"
cat > /tmp/input.txt << 'EOF'
Hadoop es un framework de software distribuido.
Hadoop permite el procesamiento distribuido de grandes conjuntos de datos.
MapReduce es el modelo de programación de Hadoop.
HDFS es el sistema de archivos distribuido de Hadoop.
YARN gestiona los recursos del cluster de Hadoop.
El procesamiento paralelo mejora el rendimiento del cluster.
Hadoop utiliza múltiples nodos para procesar datos.
La comunicación entre nodos es fundamental en Hadoop.
El balanceo de carga optimiza el rendimiento.
Hadoop es escalable y tolerante a fallos.
EOF

# Duplicar contenido para hacer el archivo más grande
for i in {1..1000}; do
  cat /tmp/input.txt >> /tmp/bigfile.txt
done

echo "Archivo de texto creado con $(wc -l < /tmp/bigfile.txt) líneas"
echo ""

# Subir a HDFS
echo -e "${YELLOW}Subiendo archivo a HDFS...${NC}"
hdfs dfs -mkdir -p /input
hdfs dfs -put -f /tmp/bigfile.txt /input/
echo ""

# Ejecutar trabajo MapReduce WordCount
echo -e "${YELLOW}Ejecutando trabajo MapReduce WordCount...${NC}"
echo "Esto mostrará la comunicación entre nodos y el uso de recursos..."
echo ""

START_TIME=$(date +%s)
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input/bigfile.txt /output
END_TIME=$(date +%s)
MAPREDUCE_TIME=$((END_TIME - START_TIME))
echo ""
echo "Tiempo de ejecución MapReduce: ${MAPREDUCE_TIME} segundos"
echo ""

# Mostrar resultados
echo -e "${YELLOW}Top 10 palabras más frecuentes:${NC}"
hdfs dfs -cat /output/part-r-00000 | sort -k2 -nr | head -10
echo ""

echo -e "${CYAN}=== 4. BENCHMARK DE RENDIMIENTO ===${NC}"
echo ""

# TestDFSIO - Benchmark de escritura
echo -e "${YELLOW}Ejecutando benchmark de escritura (TestDFSIO)...${NC}"
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -write -nrFiles 3 -fileSize 10MB
echo ""

# TestDFSIO - Benchmark de lectura
echo -e "${YELLOW}Ejecutando benchmark de lectura (TestDFSIO)...${NC}"
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-*-tests.jar \
  TestDFSIO -read -nrFiles 3 -fileSize 10MB
echo ""

echo -e "${CYAN}=== 5. ESTADÍSTICAS DE USO DE RECURSOS ===${NC}"
echo ""

echo -e "${YELLOW}Métricas de YARN:${NC}"
yarn top
echo ""

echo -e "${GREEN}======================================"
echo "PRUEBAS COMPLETADAS"
echo "======================================${NC}"
echo ""
echo "Para limpiar los archivos de prueba:"
echo "  hdfs dfs -rm -r /input /output /testfile /TestDFSIO*"
echo "  rm /tmp/testfile /tmp/testfile_downloaded /tmp/input.txt /tmp/bigfile.txt"
