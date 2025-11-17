#!/bin/bash

PORT=${1:-8000}
BASE_URL="http://localhost:$PORT"

echo "========================================="
echo "  TEST VALIDACIONES"
echo "========================================="

echo ""
echo "1. Email duplicado (debe dar error)"
curl -s -X POST "$BASE_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"duplicate@test.com"}' > /dev/null

RESPONSE=$(curl -s -X POST "$BASE_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test2","email":"duplicate@test.com"}')

if echo "$RESPONSE" | grep -q "already registered"; then
    echo "OK: Email duplicado rechazado"
else
    echo "ERROR: Acepto email duplicado"
fi
echo ""

echo "2. Proyecto con owner inexistente"
RESPONSE=$(curl -s -X POST "$BASE_URL/projects/" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","owner_user_id":99999}')

if echo "$RESPONSE" | grep -q "not found"; then
    echo "OK: Owner inexistente rechazado"
else
    echo "ERROR: Acepto owner inexistente"
fi
echo ""

echo "3. Tarea con proyecto inexistente"
RESPONSE=$(curl -s -X POST "$BASE_URL/tasks/" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","project_id":99999,"assignee_user_id":1}')

if echo "$RESPONSE" | grep -q "not found"; then
    echo "OK: Proyecto inexistente rechazado"
else
    echo "ERROR: Acepto proyecto inexistente"
fi

echo ""
echo "========================================="
echo "  TEST VALIDACIONES COMPLETADO"
echo "========================================="