# Scripts de Validación - Monolito

Scripts para probar el cambio a monolito

## Requisitos

- Servidor corriendo en puerto 8000
- curl instalado
- python3 instalado

## Uso
```bash
# damos permiso
chmod +x *.sh

#para correr todos los tests
./run_all_tests.sh

# test individuales
./test_rest.sh          # CRUD REST completo
./test_soap.sh          # Endpoint SOAP/XML
./test_performance.sh   # Medición de latencia
./test_acid.sh          # Transacciones atómicas
./test_validations.sh   # Validaciones de datos
./test_crud.sh          # Operaciones CRUD
```

## Scripts

| Script | Que prueba |
|--------|------------|
| test_rest.sh | Endpoints REST, crear user/project/task |
| test_soap.sh | SOAP con XML, ListAllUsers, CreateUser |
| test_performance.sh | Latencia al crear tareas |
| test_acid.sh | Task + Activity en misma transacción |
| test_validations.sh | Rechaza datos inválidos (nuestra validaciones) |
| test_crud.sh | Create, Read, Update, Delete |
| run_all_tests.sh | Ejecuta REST + SOAP + Performance |

## Iniciar servidor
```bash
cd monolito
python3 -m uvicorn app.main:app --reload --port 8000
```