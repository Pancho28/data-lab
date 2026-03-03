# Usamos la base oficial de code-server
FROM codercom/code-server:latest

USER root

# 1. Instalar dependencias del sistema (Blindaje para compilación)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-full \
    python3-dev \
    build-essential \
    libffi-dev \
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

# 3. Crear un entorno virtual de Python y activarlo
ENV VIRTUAL_ENV=/home/coder/project/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 4. Instalar dependencias paso a paso (Mejor para debugging y caché)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir polars pandas
RUN pip install --no-cache-dir pyspark
RUN pip install --no-cache-dir dbt-core dbt-redshift
RUN pip install --no-cache-dir google-generativeai

# 5. Asegurar permisos finales como ROOT antes de cambiar a CODER
USER root

# Corregir permisos de la carpeta project y el volumen montado
RUN chown -R coder:coder /home/coder/project && \
    chmod -R 755 /home/coder/project

# 6. Configurar el comando de inicio para forzar permisos en el arranque
# Esto ayuda si el volumen se monta con permisos de root en el despliegue
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]

USER coder

# Variables de entorno para Spark
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

EXPOSE 8080
