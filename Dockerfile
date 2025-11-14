# Usamos una imagen base de Python ligera
FROM python:3.11-slim

# Variables de entorno para Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Crear directorio de la app
WORKDIR /app

# Instalar dependencias del sistema necesarias para wkhtmltopdf
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
    wkhtmltopdf \
 && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar paquetes de Python
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copiar toda la app
COPY . /app

# Puerto que Render asigna
ENV PORT 10000

# Comando por defecto para levantar Flask con Gunicorn
# Se asume que tu Flask app se llama "app" dentro de app.py: app = Flask(__name__)
CMD exec gunicorn --bind 0.0.0.0:$PORT app:app --workers 3
