#!/bin/bash

PORT=${1:-8000}
BASE_URL="http://localhost:$PORT"

echo "========================================="
echo "  TEST TRANSACCIONES ACID"
echo "========================================="

echo ""
echo "1. Crear tarea (debe crear task + activity atomicamente)"
TASK=$(curl -s -X POST "$BASE_URL/tasks/" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test ACID","project_id":1,"assignee_user_id":1}')

TASK_ID=$(echo "$TASK" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
ACTIVITIES=$(echo "$TASK" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['activities']))" 2>/dev/null)

echo "Task ID: $TASK_ID"
echo "Actividades creadas: $ACTIVITIES"

if [ "$ACTIVITIES" == "1" ]; then
    echo "ACID OK: Task y Activity creados en misma transaccion"
else
    echo "ERROR: Fallo transaccion ACID"
fi
echo ""

echo "2. Actualizar tarea (debe agregar activity)"
curl -s -X PUT "$BASE_URL/tasks/$TASK_ID" \
  -H "Content-Type: application/json" \
  -d '{"status":"completed"}' > /dev/null

ACTS=$(curl -s "$BASE_URL/tasks/$TASK_ID/activities" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null)
echo "Actividades totales: $ACTS"

if [ "$ACTS" == "2" ]; then
    echo "ACID OK: Update registro actividad"
else
    echo "ERROR: No se registro actividad"
fi

echo ""
echo "========================================="
echo "  TEST ACID COMPLETADO"
echo "========================================="