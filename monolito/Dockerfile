FROM python:3.11-slim

WORKDIR /app

#instalar dependencias del sistema para lxml
RUN apt-get update && apt-get install -y \
    gcc \
    libxml2-dev \
    libxslt-dev \
    && rm -rf /var/lib/apt/lists/*

#copiar requirements e instalar dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#copiar código de la aplicación
COPY app/ ./app/

#exponer puerto
EXPOSE 8000

#comando para ejecutar
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]