# Base oficial de code-server
FROM codercom/code-server:latest

USER root

# 1. Instalación de dependencias de sistema
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-full python3-dev \
    build-essential libffi-dev default-jdk git curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Preparar el directorio de trabajo
RUN mkdir -p /home/coder/project && chown -R coder:coder /home/coder/project

USER coder
WORKDIR /home/coder/project

# 3. Entorno virtual
ENV VIRTUAL_ENV=/home/coder/project/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 4. Instalación de dependencias paso a paso
# Actualizar herramientas de empaquetado
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# SOLUCIÓN AL ERROR: Instalar el binario de psycopg2 para dbt-redshift
RUN pip install --no-cache-dir psycopg2-binary

# Instalar el resto del stack de Data Engineering
RUN pip install --no-cache-dir polars pandas pyspark dbt-core dbt-redshift google-generativeai

USER root

# 5. GESTIÓN DEL SCRIPT DE ARRANQUE
# Copiamos el archivo desde tu repositorio local al sistema de la imagen
COPY start-code-server.sh /usr/bin/start-code-server.sh

# Aseguramos permisos de ejecución y propiedad
RUN chmod +x /usr/bin/start-code-server.sh && \
    chown coder:coder /usr/bin/start-code-server.sh

# 6. Configuración final de ejecución
ENTRYPOINT ["/usr/bin/start-code-server.sh"]

USER coder
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
EXPOSE 8080
