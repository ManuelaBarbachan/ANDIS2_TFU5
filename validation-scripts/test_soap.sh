#!/bin/bash

PORT=${1:-8000}
BASE_URL="http://localhost:$PORT"

echo "========================================="
echo "  TESTING SOAP ENDPOINT - XML"
echo "========================================="

echo ""
echo "1. GetServiceInfo"
curl -s -X POST "$BASE_URL/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:tns="http://monolito.projectmanager.soap">
  <soap:Body>
    <tns:GetServiceInfo/>
  </soap:Body>
</soap:Envelope>'
echo ""
echo ""

echo "2. CreateUser via SOAP"
curl -s -X POST "$BASE_URL/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:tns="http://monolito.projectmanager.soap">
  <soap:Body>
    <tns:CreateUser>
      <tns:name>Usuario SOAP</tns:name>
      <tns:email>soap.user@test.com</tns:email>
    </tns:CreateUser>
  </soap:Body>
</soap:Envelope>'
echo ""
echo ""

echo "3. ListAllUsers"
curl -s -X POST "$BASE_URL/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:tns="http://monolito.projectmanager.soap">
  <soap:Body>
    <tns:ListAllUsers/>
  </soap:Body>
</soap:Envelope>'
echo ""
echo ""

echo "4. GetUserById"
curl -s -X POST "$BASE_URL/soap" \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:tns="http://monolito.projectmanager.soap">
  <soap:Body>
    <tns:GetUserById>
      <tns:user_id>1</tns:user_id>
    </tns:GetUserById>
  </soap:Body>
</soap:Envelope>'
echo ""
echo ""

echo "========================================="
echo "  PRUEBAS SOAP COMPLETADAS"
echo "========================================="