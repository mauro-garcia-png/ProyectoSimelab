# Imagen base con Debian/Ubuntu ligera y Python
FROM python:3.11-slim

# variables de entorno
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Crear carpeta de la app
WORKDIR /app

# Instalar dependencias del sistema necesarias para wkhtmltopdf
# instalamos wkhtmltopdf y las libs necesarias
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    fontconfig \
    libxrender1 \
    libxext6 \
    libfreetype6 \
    libpng16-16 \
    libjpeg62-turbo \
    libx11-6 \
    libssl-dev \
    libxkbcommon0 \
    xfonts-75dpi \
    xfonts-base \
 && rm -rf /var/lib/apt/lists/*

# Instalar wkhtmltopdf (paquete precompilado)
# Usamos una versión conocida estable; descargar binario oficial o paquete .deb
RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
 && rm -rf /var/lib/apt/lists/*

# Copiar requirements y instalar
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . /app

# Exponer puerto (Render asigna $PORT, usaremos $PORT en gunicorn)
ENV PORT 10000

# Comando por defecto usando gunicorn y la variable de entorno PORT
# Asume que tu app se expone como "app" en app.py: por ejemplo `app = Flask(__name__)`
CMD exec gunicorn --bind 0.0.0.0:$PORT app:app --workers 3
