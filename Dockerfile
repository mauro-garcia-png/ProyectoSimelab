# Imagen base con Debian/Ubuntu ligera y Python
FROM python:3.11-slim

# variables de entorno
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Crear carpeta de la app
WORKDIR /app

# Instalar dependencias del sistema necesarias para wkhtmltopdf
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    xfonts-75dpi \
    xfonts-base \
    libxrender1 \
    libjpeg62-turbo \
    libpng16-16 \
    libssl-dev \
    libxext6 \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Instalar wkhtmltopdf (versión estable para Debian Bookworm)
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bookworm_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6-1.bookworm_amd64.deb || apt-get --fix-broken install -y && \
    rm wkhtmltox_0.12.6-1.bookworm_amd64.deb

# Copiar requirements e instalar paquetes Python
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copiar todo el código de la app
COPY . /app

# Exponer puerto para Render ($PORT)
ENV PORT 10000

# Comando de arranque usando Gunicorn
CMD exec gunicorn --bind 0.0.0.0:$PORT app:app --workers 3
