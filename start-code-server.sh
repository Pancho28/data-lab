#!/bin/bash
# Salir inmediatamente si un comando falla
set -e

echo "🔧 Configurando entorno persistente del Data Lab..."

# Definir rutas clave
PROJECT_DIR="/home/coder/project"
PERSISTENT_CONTINUE="$PROJECT_DIR/.continue_config"
HOME_CONTINUE="/home/coder/.continue"

# 1. Asegurar que la carpeta de configuración existe en el volumen persistente
if [ ! -d "$PERSISTENT_CONTINUE" ]; then
    mkdir -p "$PERSISTENT_CONTINUE"
    echo "📁 Carpeta de configuración creada en el volumen."
fi

# 2. Gestión del enlace simbólico para la extensión Continue
# Si existe una carpeta real (no link) en el home, la borramos para que no estorbe
if [ -d "$HOME_CONTINUE" ] && [ ! -L "$HOME_CONTINUE" ]; then
    rm -rf "$HOME_CONTINUE"
fi

# Crear el enlace simbólico si no existe ya
if [ ! -L "$HOME_CONTINUE" ]; then
    ln -s "$PERSISTENT_CONTINUE" "$HOME_CONTINUE"
    echo "🔗 Enlace simbólico de Continue vinculado al volumen."
fi

# 3. Asegurar estructura de carpetas de trabajo (incluyendo debug para tus tests)
mkdir -p "$PROJECT_DIR/debug"
mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/data"

echo "🚀 Iniciando code-server..."

# Ejecutar el entrypoint original reemplazando el proceso actual (exec)
# Pasamos tus parámetros de red y la ruta de extensiones persistente
exec /usr/bin/entrypoint.sh \
    --bind-addr 0.0.0.0:8080 \
    --extensions-dir "$PROJECT_DIR/.extensions" \
    "."
