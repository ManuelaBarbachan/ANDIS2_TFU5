#!/bin/bash

PORT=${1:-8000}

echo "╔════════════════════════════════════════╗"
echo "║  PRUEBAS COMPLETAS - MONOLITO          ║"
echo "╚════════════════════════════════════════╝"
echo ""

#verificar servidor
if ! curl -s "http://localhost:$PORT/health" > /dev/null 2>&1; then
    echo "Servidor no está corriendo en puerto $PORT"
    echo "Iniciá con: cd monolito && python3 -m uvicorn app.main:app --port $PORT"
    exit 1
fi
echo "Servidor activo"
echo ""

chmod +x *.sh 2>/dev/null

echo "=== PARTE 1: REST ==="
./test_rest.sh $PORT
echo ""

echo "=== PARTE 2: SOAP ==="
./test_soap.sh $PORT
echo ""

echo "=== PARTE 3: ACID ==="
./test_acid.sh $PORT
echo ""

echo "=== PARTE 4: VALIDACIONES ==="
./test_validations.sh $PORT
echo ""

echo "=== PARTE 5: CRUD ==="
./test_crud.sh $PORT
echo ""

echo "=== PARTE 6: RENDIMIENTO ==="
./test_performance.sh $PORT
echo ""

echo "╔════════════════════════════════════════╗"
echo "║  TODAS LAS PRUEBAS COMPLETADAS         ║"
echo "╚════════════════════════════════════════╝"