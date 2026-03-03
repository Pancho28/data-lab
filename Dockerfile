# Usamos la base oficial de code-server
FROM codercom/code-server:latest

USER root

# 1. Instalar dependencias del sistema (Incluimos python3-venv y python3-full)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-full \
    default-jdk \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Crear la estructura de carpetas
RUN mkdir -p /home/coder/project/debug \
    && mkdir -p /home/coder/project/src \
    && mkdir -p /home/coder/project/data \
    && chown -R coder:coder /home/coder/project

USER coder
WORKDIR /home/coder/project

# 3. Crear un entorno virtual de Python y activarlo por defecto
ENV VIRTUAL_ENV=/home/coder/project/venv
RUN python3 -m venv $VIRTUAL_ENV
# Aseguramos que el PATH use primero el entorno virtual
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 4. Instalar las herramientas ahora dentro del entorno virtual (sin --break-system-packages)
RUN pip install --no-cache-dir \
    polars \
    pyspark \
    dbt-core \
    dbt-redshift \
    google-generativeai \
    pandas

# Variables de entorno para Spark
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Exponer el puerto por defecto de code-server
EXPOSE 8080
