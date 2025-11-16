#!/bin/bash

PORT=${1:-8000}
BASE_URL="http://localhost:$PORT"

echo "========================================="
echo "  TESTING REST ENDPOINTS - MONOLITO"
echo "========================================="

echo ""
echo "1. Health Check"
curl -s "$BASE_URL/health" | python3 -m json.tool
echo ""

echo "2. Crear Usuario"
USER_RESPONSE=$(curl -s -X POST "$BASE_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Manuela","email":"manuela@test.com"}')
echo "$USER_RESPONSE" | python3 -m json.tool
USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
echo ""

echo "3. Listar Usuarios"
curl -s "$BASE_URL/users/" | python3 -m json.tool
echo ""

echo "4. Crear Proyecto"
PROJECT_RESPONSE=$(curl -s -X POST "$BASE_URL/projects/" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"TFU Monolito\",\"description\":\"Proyecto monolítico\",\"owner_user_id\":$USER_ID}")
echo "$PROJECT_RESPONSE" | python3 -m json.tool
PROJECT_ID=$(echo "$PROJECT_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
echo ""

echo "5. Crear Tarea (TRANSACCIÓN ACID)"
TASK_RESPONSE=$(curl -s -X POST "$BASE_URL/tasks/" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Implementar SOAP\",\"project_id\":$PROJECT_ID,\"assignee_user_id\":$USER_ID}")
echo "$TASK_RESPONSE" | python3 -m json.tool
TASK_ID=$(echo "$TASK_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "1")
echo ""

echo "6. Ver Actividades (prueba ACID)"
curl -s "$BASE_URL/tasks/$TASK_ID/activities" | python3 -m json.tool
echo ""

echo "7. Actualizar Tarea"
curl -s -X PUT "$BASE_URL/tasks/$TASK_ID" \
  -H "Content-Type: application/json" \
  -d '{"status":"in_progress"}' | python3 -m json.tool
echo ""

echo "8. Tareas del Proyecto"
curl -s "$BASE_URL/projects/$PROJECT_ID/tasks" | python3 -m json.tool
echo ""

echo "========================================="
echo "  PRUEBAS REST COMPLETADAS"
echo "========================================="