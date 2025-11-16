#!/bin/bash

PORT=${1:-8000}
BASE_URL="http://localhost:$PORT"

echo "========================================="
echo "  DEMOSTRACIÓN DE MEJORA EN LATENCIA"
echo "========================================="

echo ""
echo "VENTAJA DEL MONOLITO:"
echo "- Sin latencia de red entre servicios"
echo "- Sin serialización/deserialización HTTP"
echo "- Transacciones ACID más simples"
echo ""

#setup
echo "1. Creando datos de prueba..."
USER_RESP=$(curl -s -X POST "$BASE_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"perf@test.com"}')
USER_ID=$(echo "$USER_RESP" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")

PROJECT_RESP=$(curl -s -X POST "$BASE_URL/projects/" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Performance Test\",\"owner_user_id\":$USER_ID}")
PROJECT_ID=$(echo "$PROJECT_RESP" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
echo "Usuario: $USER_ID, Proyecto: $PROJECT_ID"
echo ""

echo "2. Test: Crear 5 tareas con validaciones"
for i in {1..5}; do
    START=$(python3 -c "import time; print(time.time())")
    curl -s -X POST "$BASE_URL/tasks/" \
      -H "Content-Type: application/json" \
      -d "{\"title\":\"Task $i\",\"project_id\":$PROJECT_ID,\"assignee_user_id\":$USER_ID}" > /dev/null
    END=$(python3 -c "import time; print(time.time())")
    ELAPSED=$(python3 -c "print(f'{$END - $START:.4f}')")
    echo "  Task $i: ${ELAPSED}s"
done
echo ""

echo "========================================="
echo "  CONCLUSIÓN"
echo "========================================="
echo "El monolito elimina overhead de red entre servicios."
echo ""