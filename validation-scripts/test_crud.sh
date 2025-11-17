#!/bin/bash

PORT=${1:-8000}
BASE_URL="http://localhost:$PORT"

echo "========================================="
echo "  TEST CRUD COMPLETO"
echo "========================================="

echo ""
echo "=== USERS ==="
echo "CREATE:"
USER=$(curl -s -X POST "$BASE_URL/users/" \
  -H "Content-Type: application/json" \
  -d '{"name":"CRUD Test","email":"crud'$RANDOM'@test.com"}')
USER_ID=$(echo "$USER" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
echo "User ID: $USER_ID"

echo "READ:"
curl -s "$BASE_URL/users/$USER_ID" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'  {d[\"name\"]} - {d[\"email\"]}')"

echo "UPDATE:"
curl -s -X PUT "$BASE_URL/users/$USER_ID" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name"}' | python3 -c "import sys, json; print(f'  Nuevo nombre: {json.load(sys.stdin)[\"name\"]}')"

echo "DELETE:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/users/$USER_ID")
if [ "$HTTP_CODE" == "204" ]; then
    echo "  Eliminado OK"
else
    echo "  Error: $HTTP_CODE"
fi

echo ""
echo "========================================="
echo "  TEST CRUD COMPLETADO"
echo "========================================="