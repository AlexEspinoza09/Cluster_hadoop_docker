#!/bin/bash

echo "======================================"
echo "Iniciando Servicios de Hadoop"
echo "======================================"
echo ""

# Iniciar SSH en todos los nodos
echo "Iniciando servicio SSH en todos los nodos..."
docker exec hadoop-master bash -c "sudo service ssh start"
docker exec hadoop-worker1 bash -c "sudo service ssh start"
docker exec hadoop-worker2 bash -c "sudo service ssh start"
echo "  ✓ SSH iniciado"
echo ""

# Copiar claves SSH entre nodos
echo "Configurando SSH sin contraseña entre nodos..."
for node in hadoop-master hadoop-worker1 hadoop-worker2; do
    docker exec $node bash -c "echo 'StrictHostKeyChecking no' >> /home/hadoop/.ssh/config"
    docker exec $node bash -c "chown hadoop:hadoop /home/hadoop/.ssh/config"
    docker exec $node bash -c "chmod 600 /home/hadoop/.ssh/config"
done

# Intercambiar claves SSH
docker exec hadoop-master bash -c "su - hadoop -c 'cat /home/hadoop/.ssh/id_rsa.pub'" > /tmp/master_key.pub
docker exec hadoop-worker1 bash -c "su - hadoop -c 'cat /home/hadoop/.ssh/id_rsa.pub'" > /tmp/worker1_key.pub
docker exec hadoop-worker2 bash -c "su - hadoop -c 'cat /home/hadoop/.ssh/id_rsa.pub'" > /tmp/worker2_key.pub

for node in hadoop-master hadoop-worker1 hadoop-worker2; do
    docker exec -i $node bash -c "cat >> /home/hadoop/.ssh/authorized_keys" < /tmp/master_key.pub
    docker exec -i $node bash -c "cat >> /home/hadoop/.ssh/authorized_keys" < /tmp/worker1_key.pub
    docker exec -i $node bash -c "cat >> /home/hadoop/.ssh/authorized_keys" < /tmp/worker2_key.pub
    docker exec $node bash -c "chown hadoop:hadoop /home/hadoop/.ssh/authorized_keys"
    docker exec $node bash -c "chmod 600 /home/hadoop/.ssh/authorized_keys"
done

rm -f /tmp/master_key.pub /tmp/worker1_key.pub /tmp/worker2_key.pub
echo "  ✓ SSH configurado sin contraseña"
echo ""

# Crear directorios necesarios en HDFS
echo "Iniciando HDFS..."
docker exec -u hadoop hadoop-master bash -c "start-dfs.sh"
echo "  ✓ HDFS iniciado"
echo ""

sleep 5

# Crear directorios para Job History Server
echo "Creando directorios en HDFS..."
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -mkdir -p /mr-history/tmp"
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -mkdir -p /mr-history/done"
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -chmod -R 1777 /mr-history"
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -mkdir -p /tmp"
docker exec -u hadoop hadoop-master bash -c "hdfs dfs -chmod 1777 /tmp"
echo "  ✓ Directorios HDFS creados"
echo ""

# Iniciar YARN
echo "Iniciando YARN..."
docker exec -u hadoop hadoop-master bash -c "start-yarn.sh"
echo "  ✓ YARN iniciado"
echo ""

# Iniciar Job History Server
echo "Iniciando Job History Server..."
docker exec -u hadoop hadoop-master bash -c "mapred --daemon start historyserver"
echo "  ✓ Job History Server iniciado"
echo ""

sleep 3

echo "======================================"
echo "Hadoop Cluster Iniciado!"
echo "======================================"
echo ""
echo "Verificando servicios..."
docker exec -u hadoop hadoop-master bash -c "jps"
echo ""
echo "Interfaces Web disponibles:"
echo "  - NameNode UI:        http://localhost:9870"
echo "  - ResourceManager UI: http://localhost:8088"
echo "  - Job History Server: http://localhost:19888"
echo "  - DataNode 1 UI:      http://localhost:9864"
echo "  - DataNode 2 UI:      http://localhost:9865"
echo ""
echo "Para verificar el estado del cluster:"
echo "  hdfs dfsadmin -report"
echo "  yarn node -list"
