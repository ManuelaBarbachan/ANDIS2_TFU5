#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║  SETUP LOCAL - MONOLITO                ║"
echo "╚════════════════════════════════════════╝"
echo ""

#verificar Python
if ! command -v python3 &> /dev/null; then
    echo "Python 3 no encontrado. Instalalo primero."
    exit 1
fi

echo "Python 3 encontrado: $(python3 --version)"
echo ""

#instalar dependencias
echo "Instalando dependencias..."
cd monolito
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "dependencias instaladas correctamente"
else
    echo "error instalando dependencias"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  SETUP COMPLETADO                      ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "para ejecutar la aplicación:"
echo ""
echo "  cd monolito"
echo "  uvicorn app.main:app --reload --port 8000"
echo ""
echo "luego abrí en el navegador:"
echo "  http://localhost:8000/docs  (Swagger UI)"
echo "  http://localhost:8000/health"
echo ""