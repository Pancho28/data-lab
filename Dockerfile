# Usamos la base oficial de code-server
FROM codercom/code-server:latest

USER root

# 1. Instalar dependencias del sistema: Java (para Spark) y Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    default-jdk \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Crear la estructura de carpetas que acordamos
RUN mkdir -p /home/coder/project/debug \
    && mkdir -p /home/coder/project/src \
    && mkdir -p /home/coder/project/data

# 3. Instalar las herramientas base del plan de estudio
# Polars, PySpark, dbt (para Postgres/Redshift) y la API de Gemini para Antigravity
RUN pip3 install --no-cache-dir \
    polars \
    pyspark \
    dbt-core \
    dbt-redshift \
    google-generativeai \
    pandas

# 4. Ajustar permisos para que el usuario 'coder' pueda escribir
RUN chown -R coder:coder /home/coder/project

USER coder

# Variables de entorno para Spark
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:/home/coder/.local/bin

WORKDIR /home/coder/project
