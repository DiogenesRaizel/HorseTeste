#!/bin/bash

BASE_URL="http://127.0.0.1:9000"

PASS=0
FAIL=0

test_status() {
    local descricao="$1"
    local esperado="$2"
    local metodo="$3"
    local url="$4"
    local dados="$5"

    if [ -n "$dados" ]; then
        resultado=$(curl -s -o /dev/null -w "%{http_code}" \
            -X "$metodo" \
            "$url" \
            -H "Content-Type: application/json" \
            -d "$dados")
    else
        resultado=$(curl -s -o /dev/null -w "%{http_code}" \
            -X "$metodo" \
            "$url")
    fi

    if [ "$resultado" = "$esperado" ]; then
        echo "[OK]   $descricao ($resultado)"
        ((PASS++))
    else
        echo "[ERRO] $descricao (esperado: $esperado, recebido: $resultado)"
        ((FAIL++))
    fi
}

echo
echo "======================================"
echo " Testes de Integracao - HorseTeste"
echo "======================================"
echo

echo "--- GET ---"

test_status \
    "Listar produtos" \
    "200" \
    "GET" \
    "$BASE_URL/produtos"

test_status \
    "Buscar produto existente" \
    "200" \
    "GET" \
    "$BASE_URL/produtos/1"

test_status \
    "Buscar produto inexistente" \
    "404" \
    "GET" \
    "$BASE_URL/produtos/999"

test_status \
    "Buscar produto com ID invalido" \
    "400" \
    "GET" \
    "$BASE_URL/produtos/abc"

echo
echo "--- POST ---"

test_status \
    "Criar produto valido" \
    "201" \
    "POST" \
    "$BASE_URL/produtos" \
    '{"nome":"Teste Integracao","preco":10,"estoque":5}'

test_status \
    "Nome vazio" \
    "400" \
    "POST" \
    "$BASE_URL/produtos" \
    '{"nome":"","preco":10,"estoque":5}'

test_status \
    "Preco negativo" \
    "400" \
    "POST" \
    "$BASE_URL/produtos" \
    '{"nome":"Teste","preco":-10,"estoque":5}'

test_status \
    "Estoque negativo" \
    "400" \
    "POST" \
    "$BASE_URL/produtos" \
    '{"nome":"Teste","preco":10,"estoque":-5}'

echo
echo "--- PUT ---"

test_status \
    "Atualizar produto existente" \
    "200" \
    "PUT" \
    "$BASE_URL/produtos/1" \
    '{"nome":"Arroz Atualizado","preco":10,"estoque":20}'

test_status \
    "Atualizar produto inexistente" \
    "404" \
    "PUT" \
    "$BASE_URL/produtos/999" \
    '{"nome":"Produto Inexistente","preco":10,"estoque":5}'

echo
echo "--- DELETE ---"

test_status \
    "Excluir produto inexistente" \
    "404" \
    "DELETE" \
    "$BASE_URL/produtos/999"

echo
echo "--- PATCH ---"

test_status \
    "Metodo PATCH nao implementado" \
    "404" \
    "PATCH" \
    "$BASE_URL/produtos/1"

echo
echo "======================================"
echo " Resultado"
echo "======================================"
echo "OK:    $PASS"
echo "ERROS: $FAIL"
echo

if [ "$FAIL" -eq 0 ]; then
    echo "TODOS OS TESTES PASSARAM."
    exit 0
else
    echo "EXISTEM TESTES COM FALHA."
    exit 1
fi
