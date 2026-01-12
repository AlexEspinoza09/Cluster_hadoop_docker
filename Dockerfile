# Dockerfile para nodos del cluster Hadoop
FROM ubuntu:22.04

# Evitar interacción durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    ssh \
    rsync \
    vim \
    net-tools \
    iputils-ping \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario hadoop
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop:hadoop" | chpasswd && \
    adduser hadoop sudo && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configurar SSH sin contraseña
RUN mkdir -p /home/hadoop/.ssh && \
    ssh-keygen -t rsa -P '' -f /home/hadoop/.ssh/id_rsa && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chmod 0600 /home/hadoop/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /home/hadoop/.ssh

# Configurar SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Descargar e instalar Hadoop 3.3.6
RUN wget --no-check-certificate https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    echo "Verificando descarga..." && \
    ls -lh hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz -C /opt/ && \
    mv /opt/hadoop-3.3.6 /opt/hadoop && \
    echo "Verificando instalación de Hadoop..." && \
    ls -lh /opt/hadoop/share/hadoop/yarn/*.jar | head -5 && \
    rm hadoop-3.3.6.tar.gz

# Variables de entorno para Java y Hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV HADOOP_MAPRED_HOME=/opt/hadoop
ENV HADOOP_COMMON_HOME=/opt/hadoop
ENV HADOOP_HDFS_HOME=/opt/hadoop
ENV YARN_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin

# Configurar JAVA_HOME en hadoop-env.sh
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> $HADOOP_CONF_DIR/hadoop-env.sh

# Crear directorios para datos de Hadoop
RUN mkdir -p /opt/hadoop/data/nameNode && \
    mkdir -p /opt/hadoop/data/dataNode && \
    mkdir -p /opt/hadoop/data/tmp && \
    chown -R hadoop:hadoop /opt/hadoop

# Establecer usuario hadoop como propietario
RUN chown -R hadoop:hadoop /home/hadoop

# Puerto HDFS NameNode
EXPOSE 9870 9000 8088 19888 50070 50075 50090

# Usuario por defecto
USER hadoop
WORKDIR /home/hadoop

# Comando por defecto
CMD ["tail", "-f", "/dev/null"]
