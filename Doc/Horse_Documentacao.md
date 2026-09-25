# Relatório — Documentação do Horse e plano de evolução do HorseTeste

## 1. Objetivo

Este documento consolida o estudo da documentação do Horse realizado durante o desenvolvimento do projeto HorseTeste.

O objetivo não é implementar tudo que o Horse oferece, mas registrar:

* o que já foi utilizado;
* o que foi validado na prática;
* o que deve ser implementado;
* o que pode ser implementado posteriormente;
* em que momento cada recurso passa a fazer sentido;
* o que não é necessário para o projeto atual.

O projeto considera como base:

* Lazarus 4.8
* Free Pascal 3.2.2
* Ubuntu Linux
* Horse 3.3.9
* Jhonson 1.2.5
* Epoll
* Zeos
* SQLite

Uma regra adotada durante o estudo foi:

> Compatibilidade declarada pelo Horse não significa automaticamente compatibilidade comprovada com Lazarus 4.8 + FPC 3.2.2 + Linux.

Recursos que dependem de providers, bibliotecas ou versões específicas devem ser testados na toolchain real antes de serem adotados.

---

# 2. Estado atual do HorseTeste

A aplicação atualmente possui a seguinte estrutura:

```text
HTTP
 │
 ▼
Horse
 │
 ▼
Epoll
 │
 ▼
Controller
 │
 ▼
Service
 │
 ▼
Repository
 │
 ▼
SQLite
```

O projeto já possui:

* servidor HTTP;
* provider Epoll;
* rotas REST;
* JSON;
* CRUD de produtos;
* busca;
* validação de negócio;
* tratamento de erros de validação;
* Repository por interface;
* Service;
* Controllers;
* injeção de dependências;
* persistência com Zeos;
* SQLite;
* frontend HTML;
* testes de integração;
* testes automatizados com Bash + curl.

Os testes de integração realizados apresentaram:

```text
OK:    12
ERROS: 0
```

---

# 3. Recursos da documentação que já utilizamos

## 3.1 Horse

### Situação

**IMPLEMENTADO**

O Horse é o núcleo HTTP da aplicação.

Utilizamos:

```pascal
THorse.Get(...)
THorse.Post(...)
THorse.Put(...)
THorse.Delete(...)
THorse.Listen(...)
```

Também utilizamos os objetos:

```pascal
THorseRequest
THorseResponse
```

### Momento

Já implementado.

---

# 4. Epoll

## Situação

**IMPLEMENTADO E VALIDADO**

O projeto utiliza:

```text
HORSE_PROVIDER_EPOLL
```

com:

```text
FPC 3.2.2
Linux
Horse 3.3.9
```

O servidor foi compilado e executado com sucesso.

### Função

Epoll pertence à infraestrutura de transporte HTTP.

Ele não participa da arquitetura MVC:

```text
Epoll
  ↓
HTTP
  ↓
Controller
  ↓
Service
```

Portanto, não deve receber regras de negócio ou decisões da aplicação.

### Momento

Já implementado.

### Observação

Não há motivo para trocar o Epoll no projeto atual.

---

# 5. Jhonson

## Situação

**IMPLEMENTADO**

Utilizado como middleware:

```pascal
THorse.Use(Jhonson);
```

Permite trabalhar com JSON nos Controllers.

Exemplo:

```pascal
Req.Body<TJSONObject>
```

### Momento

Já implementado.

### Futuro

Continuar utilizando enquanto a aplicação trabalhar com JSON REST.

---

# 6. Request / Response

## Situação

**IMPLEMENTADO**

A aplicação utiliza:

```pascal
Req.Params['id']
Req.Query['busca']
Req.Body<TJSONObject>
```

e:

```pascal
Res.Status(...)
Res.Send(...)
Res.SendFile(...)
```

Essas APIs mantêm o código do Controller relativamente independente do provider.

### Momento

Já implementado.

### Futuro

Continuar utilizando essas abstrações antes de recorrer às APIs de baixo nível.

---

# 7. Roteamento

## Situação

**IMPLEMENTADO**

Rotas atuais:

```text
GET     /produtos
GET     /produtos/:id
POST    /produtos
PUT     /produtos/:id
DELETE  /produtos/:id
```

Também existe consulta por:

```text
/produtos?busca=...
```

As rotas estão centralizadas nos Controllers.

### Momento

Já implementado.

### Futuro

Caso a API cresça significativamente, avaliar:

* route groups;
* middleware por grupo;
* organização por módulos.

Não há motivo para isso agora.

---

# 8. Middleware

## Situação

**UTILIZADO**

O projeto já utiliza middleware através do Jhonson.

A documentação mostrou que middleware é apropriado para preocupações transversais:

```text
HTTP
 ↓
Middleware
 ↓
Controller
 ↓
Service
 ↓
Repository
```

### Futuro

Poderão ser utilizados para:

* autenticação;
* autorização;
* logging;
* request ID;
* CORS;
* métricas;
* observabilidade.

### Momento

Não adicionar middleware próprio agora.

Primeiro devem surgir necessidades concretas.

---

# 9. Tratamento de exceções

## Situação

**IMPLEMENTADO**

Foi definida uma separação clara:

```text
Service
   │
   └── EProdutoValidacao
            ↓
       Controller
            │
            └── EHorseException
                         ↓
                       Horse
```

O Service não conhece HTTP.

O Controller transforma erros de negócio em respostas HTTP.

Exceções inesperadas não são artificialmente capturadas pelo Controller.

### Momento

Já implementado.

### Regra

Não colocar:

```pascal
EHorseException
```

dentro do Service.

---

# 10. Validação

## Situação

**IMPLEMENTADO**

A validação de negócio está no Service.

Exemplo:

```text
Nome obrigatório
Preço não negativo
Estoque não negativo
ID válido
```

A aplicação não depende exclusivamente da validação do HTML/JavaScript.

### Motivo

O cliente pode ser contornado.

Portanto:

```text
HTML/JavaScript
      ↓
validação de interface

Service
      ↓
validação real de negócio
```

### Momento

Já implementado.

---

# 11. Static Files / SendFile

## Situação

**IMPLEMENTADO**

O Controller web serve:

```text
web/index.html
```

através de:

```pascal
Res.SendFile(...)
```

### Momento

Já implementado.

### Futuro

Pode continuar sendo suficiente para o frontend pequeno do laboratório.

Caso o frontend cresça muito, pode ser interessante separar frontend e backend ou utilizar Nginx/Caddy.

Não há necessidade disso agora.

---

# 12. Testes de integração

## Situação

**IMPLEMENTADO**

Foi criado:

```text
tests/test_api.sh
```

com Bash + curl.

São testados:

* GET;
* POST;
* PUT;
* DELETE;
* IDs inválidos;
* registros inexistentes;
* validações;
* método não implementado.

Resultado atual:

```text
OK:    12
ERROS: 0
```

### Momento

Já implementado.

### Futuro

Aumentar os testes conforme novos recursos forem adicionados.

Este teste deve crescer junto com a API.

---

# 13. Observabilidade e logging

## Situação

**DEVE SER IMPLEMENTADO**

A documentação mostrou três níveis:

```text
Logging
   ↓
Métricas
   ↓
Tracing / OpenTelemetry
```

Para o HorseTeste, o primeiro nível é o mais importante.

### Primeira implementação

Registrar:

```text
data/hora
método
rota
status HTTP
tempo de resposta
```

Exemplo conceitual:

```text
GET /produtos 200 12ms
POST /produtos 201 8ms
GET /produtos/999 404 3ms
```

### Momento

**Próxima fase de infraestrutura.**

Antes de autenticação complexa ou OpenTelemetry.

### Prioridade

ALTA.

---

# 14. Request ID / Correlation ID

## Situação

**DEVE SER IMPLEMENTADO JUNTO COM LOGGING**

Um identificador por requisição permitirá relacionar:

```text
requisição
   ↓
log HTTP
   ↓
erro
   ↓
operação interna
```

Exemplo:

```text
Request-ID: 8f31...
```

### Momento

Junto com a primeira implementação de logging.

### Prioridade

MÉDIA/ALTA.

---

# 15. Métricas / Prometheus

## Situação

**PODE SER IMPLEMENTADO**

Métricas poderiam registrar:

```text
total de requisições
erros HTTP
tempo médio
quantidade de respostas 4xx
quantidade de respostas 5xx
```

### Momento

Depois que o logging básico estiver funcionando.

Não há necessidade de implementar Prometheus antes de existir uma necessidade real de monitoramento.

### Prioridade

MÉDIA.

---

# 16. OpenTelemetry

## Situação

**ADIAR**

OpenTelemetry passa a ser mais interessante quando houver:

* múltiplos serviços;
* APIs externas;
* filas;
* workers;
* microserviços;
* arquitetura distribuída.

No HorseTeste atual:

```text
Horse
 ↓
Controller
 ↓
Service
 ↓
Repository
 ↓
SQLite
```

o tracing distribuído acrescentaria complexidade sem benefício proporcional.

### Momento

Somente quando a arquitetura crescer.

### Prioridade

BAIXA atualmente.

---

# 17. CORS

## Situação

**PODE SER IMPLEMENTADO**

CORS será necessário caso o frontend esteja hospedado em uma origem diferente da API.

Exemplo:

```text
Frontend
https://app.exemplo.com

API
https://api.exemplo.com
```

### Momento

Quando frontend e backend forem separados ou quando uma aplicação externa consumir a API.

### Prioridade

BAIXA atualmente.

---

# 18. Autenticação

## Situação

**DEVE SER IMPLEMENTADA ANTES DA PRODUÇÃO**

Para uma aplicação real de escritório, endpoints administrativos não devem permanecer públicos.

Arquitetura esperada:

```text
Cliente
   ↓
Autenticação
   ↓
Middleware
   ↓
Controller
   ↓
Service
```

JWT é uma possibilidade.

O Service não deve conhecer JWT.

### Momento

Antes de expor a aplicação a usuários reais em uma rede não confiável ou à Internet.

### Prioridade

ALTA para produção.

---

# 19. Autorização / permissões

## Situação

**DEVE SER IMPLEMENTADA JUNTO COM AUTENTICAÇÃO, SE NECESSÁRIO**

Autenticação responde:

```text
Quem é você?
```

Autorização responde:

```text
O que você pode fazer?
```

Exemplo:

```text
usuário comum
administrador
```

### Momento

Quando houver mais de um nível de acesso.

Não implementar papéis fictícios antes de existir uma necessidade real.

---

# 20. HTTPS / TLS

## Situação

**DEVE SER IMPLEMENTADO ANTES DE EXPOSIÇÃO EXTERNA**

A estratégia considerada mais simples é:

```text
Internet
   ↓ HTTPS :443
Nginx/Caddy
   ↓ HTTP interno
Horse :9000
   ↓
Epoll
```

O Horse continua responsável pela aplicação HTTP.

O reverse proxy cuida da terminação TLS.

### Momento

Quando o sistema sair do ambiente local/LAN controlado e precisar de acesso externo.

### Prioridade

ALTA para produção externa.

---

# 21. systemd

## Situação

**DEVE SER IMPLEMENTADO PARA PRODUÇÃO LINUX**

Atualmente:

```bash
./bin/HorseTeste
```

é suficiente para desenvolvimento.

Em produção:

```text
systemd
   ↓
HorseTeste
```

permitirá:

* iniciar automaticamente;
* reiniciar após falha;
* iniciar no boot;
* controlar o serviço;
* registrar estado do processo.

### Momento

Quando o HorseTeste for instalado como aplicação real em um servidor Linux.

### Prioridade

ALTA para produção.

---

# 22. Reverse Proxy

## Situação

**DEVE SER CONSIDERADO PARA PRODUÇÃO EXTERNA**

Nginx ou Caddy podem ficar na frente do Horse.

Arquitetura:

```text
Cliente
   ↓
HTTPS :443
   ↓
Nginx/Caddy
   ↓
Horse :9000
   ↓
Epoll
```

### Benefícios

* TLS;
* certificados;
* exposição controlada;
* possibilidade de servir arquivos estáticos;
* separação entre infraestrutura e aplicação.

### Momento

Quando houver necessidade de acesso externo ou quando o ambiente de produção justificar.

---

# 23. Streaming

## Situação

**ADIAR**

Para CRUD pequeno, respostas JSON normais são suficientes.

Streaming começa a fazer sentido para:

* arquivos grandes;
* relatórios grandes;
* exportações;
* processamento prolongado;
* grandes volumes de dados.

### Momento

Quando existir um caso real que justifique.

Não implementar apenas porque o Horse oferece suporte.

---

# 24. Web Streams / NDJSON

## Situação

**ADIAR**

NDJSON e Web Streams podem ser interessantes para grandes conjuntos de dados processados progressivamente.

No CRUD atual:

```text
GET /produtos
```

não há benefício significativo.

### Momento

Quando houver uma API que realmente precise transmitir dados progressivamente.

---

# 25. SSE — Server-Sent Events

## Situação

**PODE SER IMPLEMENTADO NO FUTURO**

SSE é particularmente interessante para um possível sistema de relatórios.

Exemplo:

```text
POST /relatorios
      ↓
202 Accepted
      ↓
fila
      ↓
worker
      ↓
relatório pronto
      ↓
SSE
      ↓
navegador
```

O servidor pode informar:

```text
relatório iniciado
relatório processando
relatório pronto
```

### Momento

Quando o sistema possuir processamento assíncrono de relatórios.

---

# 26. Fila de relatórios

## Situação

**PLANEJADA PARA O FUTURO**

Uma arquitetura possível:

```text
RelatorioController
        ↓
RelatorioService
        ↓
RelatorioQueue
        ↓
RelatorioWorker
        ↓
GeradorRelatorio
        ↓
Repository
```

A API poderia responder:

```text
202 Accepted
```

com um identificador do relatório.

O processamento ocorreria fora da requisição HTTP.

### Momento

Quando relatórios reais começarem a levar segundos ou dezenas de segundos para serem produzidos.

Não implementar antes de conhecer o tempo e o tamanho reais dos relatórios.

### Prioridade

MÉDIA/FUTURA.

---

# 27. WebSocket

## Situação

**ADIAR**

WebSocket é útil quando existe comunicação bidirecional contínua.

Para o projeto atual, REST é suficiente.

Para informar progresso de relatórios, SSE provavelmente será mais simples se a comunicação for somente:

```text
servidor → navegador
```

### Momento

Somente se aparecer uma necessidade real de comunicação bidirecional em tempo real.

### Prioridade

BAIXA.

---

# 28. Buffer Pooling

## Situação

**NÃO IMPLEMENTAR MANUALMENTE**

O Horse já possui mecanismos internos para reutilização de buffers.

Para o CRUD atual, não há motivo para manipular diretamente:

```text
THorseMemoryBufferPool
THorsePooledStream
```

### Momento

Somente em uma necessidade específica de streaming/customização de baixo nível.

### Prioridade

MUITO BAIXA.

---

# 29. Route Groups

## Situação

**ADIAR**

Route groups serão úteis quando existirem muitos endpoints ou grupos de segurança.

Exemplo futuro:

```text
/api/public
/api/auth
/api/admin
/api/relatorios
```

### Momento

Quando a quantidade de rotas justificar organização adicional.

Atualmente são poucas rotas.

---

# 30. Radix Router

## Situação

**NÃO IMPLEMENTAR AGORA**

O número de rotas atual é pequeno.

Não há problema de roteamento que justifique trocar ou otimizar a estrutura atual.

### Momento

Somente se houver uma necessidade concreta.

---

# 31. gRPC / HTTP2

## Situação

**ADIAR**

É tecnicamente interessante, mas não existe necessidade no HorseTeste atual.

REST atende ao cenário.

Uma possível arquitetura futura seria:

```text
REST Controller ──┐
                  ├── Service ── Repository
gRPC Service  ────┘
```

O Service continuaria independente do protocolo.

### Momento

Somente se outro sistema precisar de comunicação gRPC/HTTP2.

---

# 32. Providers alternativos

## Situação

### Epoll

**USAR**

Atual e validado.

### fphttpserver

**MANTER COMO CONHECIMENTO/BASELINE**

Não há motivo para trocar.

### CrossSocket

**DESCARTADO**

A versão encontrada exigia FPC mais novo que o FPC 3.2.2 utilizado pelo projeto.

### IOCP

**NÃO USAR**

Windows.

### HTTP.sys

**NÃO USAR**

Windows.

### Indy

**NÃO USAR**

Não corresponde à infraestrutura escolhida para o projeto Linux/Epoll.

### Conclusão

Não trocar o provider atual.

---

# 33. SSL/TLS nativo no Horse

## Situação

**NÃO IMPLEMENTAR AGORA**

Para produção externa, a estratégia preferencial continua sendo:

```text
HTTPS
  ↓
Nginx/Caddy
  ↓
Horse
```

Isso mantém TLS separado da aplicação.

### Momento

Na implantação externa.

---

# 34. Integridade e testes avançados

## Situação

**PARCIALMENTE UTILIZADO**

A documentação mostrou testes reais contra servidor HTTP, o que inspirou nosso:

```text
tests/test_api.sh
```

Não há necessidade de reproduzir toda a suíte interna do Horse.

### Futuro

Adicionar testes conforme a aplicação crescer.

Possíveis categorias:

```text
CRUD
validação
autenticação
autorização
relatórios
arquivos
erros
```

---

# 35. HTTP/2 e HTTP/3

## Situação

**ADIAR**

Não existe necessidade atual.

HTTP/1.1 é suficiente para o CRUD do escritório.

Caso exista uma necessidade futura de HTTP/2, deve-se validar a implementação específica na combinação:

```text
Horse 3.3.9
FPC 3.2.2
Linux
```

antes de adotar.

---

# 36. Documentação OpenAPI / Swagger

## Situação

**DEVE SER IMPLEMENTADA QUANDO A API ESTIVER MAIS ESTÁVEL**

Hoje a API ainda está em construção.

Quando os endpoints principais estiverem definidos, OpenAPI poderá documentar:

```text
rotas
parâmetros
JSON
status HTTP
erros
```

### Momento

Depois que a estrutura principal da API estiver estabilizada.

### Prioridade

MÉDIA.

---

# 37. Health Check

## Situação

**DEVE SER IMPLEMENTADO ANTES DA PRODUÇÃO**

Uma rota simples como:

```text
GET /health
```

pode informar que o servidor está ativo.

Posteriormente pode existir:

```text
GET /health
GET /ready
```

para distinguir:

```text
processo funcionando
```

de:

```text
aplicação pronta para atender
```

### Momento

Na preparação para produção.

### Prioridade

MÉDIA/ALTA.

---

# 38. Paginação

## Situação

**DEVE SER IMPLEMENTADA QUANDO OS DADOS CRESCEREM**

Atualmente:

```text
GET /produtos
```

pode retornar todos os produtos.

Quando o volume crescer, implementar:

```text
/produtos?page=1&limit=50
```

ou mecanismo equivalente.

### Momento

Quando a quantidade de registros justificar.

Não implementar apenas por antecipação.

---

# 39. Compressão

## Situação

**PODE SER IMPLEMENTADA**

Compressão HTTP pode reduzir respostas grandes.

Para pequenos JSONs:

```text
benefício baixo
```

Para:

```text
relatórios
listas grandes
arquivos
```

pode ser interessante.

### Momento

Quando houver respostas grandes.

---

# 40. Segurança de headers / hardening

## Situação

**DEVE SER IMPLEMENTADO NA PREPARAÇÃO PARA PRODUÇÃO EXTERNA**

Possíveis medidas:

* headers de segurança;
* controle de CORS;
* HTTPS;
* limites de requisição;
* controle de tamanho de payload;
* autenticação;
* autorização.

### Momento

Antes da exposição externa.

Não é prioridade para o laboratório local.

---

# 41. Resumo por momento de implementação

## Já implementado

```text
[OK] Horse
[OK] Epoll
[OK] Jhonson
[OK] REST
[OK] Request/Response
[OK] Routing
[OK] Controller
[OK] Service
[OK] Repository
[OK] DI
[OK] Validação
[OK] EHorseException
[OK] SQLite
[OK] Zeos
[OK] Static file
[OK] Testes de integração
```

---

## Próxima fase

```text
[ ] Logging HTTP
[ ] Request ID
[ ] Health Check
[ ] Melhorar suíte de testes
```

Essa é a próxima camada mais coerente.

---

## Quando a aplicação estiver funcionalmente mais completa

```text
[ ] OpenAPI / Swagger
[ ] Paginação
[ ] CORS, se necessário
[ ] Métricas
[ ] Compressão, se necessária
```

---

## Antes da produção

```text
[ ] Autenticação
[ ] Autorização, se necessária
[ ] HTTPS
[ ] Reverse Proxy
[ ] systemd
[ ] configuração por ambiente
[ ] gerenciamento de segredos
[ ] hardening
[ ] backup
[ ] monitoramento
```

---

## Quando surgirem necessidades reais

```text
[ ] Streaming
[ ] SSE
[ ] Fila de relatórios
[ ] Worker de relatórios
[ ] WebSocket
[ ] HTTP/2
[ ] gRPC
[ ] OpenTelemetry
[ ] NDJSON
```

---

## Não implementar no HorseTeste atual

```text
[ ] IOCP
[ ] HTTP.sys
[ ] CrossSocket
[ ] Radix Router
[ ] Buffer Pool manual
[ ] WebSocket sem necessidade real
[ ] OpenTelemetry prematuramente
[ ] complexidade de microserviços
```

---

# 42. Ordem recomendada de evolução

A sequência mais coerente para o projeto é:

```text
FASE 1 — FUNDAMENTO
        │
        ├── Horse
        ├── Epoll
        ├── Jhonson
        ├── REST
        ├── MVC
        ├── Service
        ├── Repository
        └── testes
                ↓
FASE 2 — OBSERVABILIDADE
        │
        ├── Logging
        ├── Request ID
        └── Health Check
                ↓
FASE 3 — API
        │
        ├── completar recursos
        ├── testes
        ├── paginação
        └── OpenAPI
                ↓
FASE 4 — SEGURANÇA
        │
        ├── autenticação
        ├── autorização
        ├── HTTPS
        └── hardening
                ↓
FASE 5 — PRODUÇÃO
        │
        ├── systemd
        ├── reverse proxy
        ├── backup
        └── monitoramento
                ↓
FASE 6 — ESCALA FUNCIONAL
        │
        ├── relatórios
        ├── fila
        ├── workers
        ├── SSE
        └── streaming
```

---

# 43. Princípio geral adotado

O estudo da documentação mostrou que o fato de o Horse possuir determinado recurso não significa que ele deva ser colocado imediatamente na aplicação.

A regra adotada para o HorseTeste é:

> Implementar uma tecnologia quando existir um problema que ela resolve, e não simplesmente porque ela existe.

Assim:

```text
problema real
     ↓
necessidade
     ↓
recurso do Horse
     ↓
teste na toolchain real
     ↓
implementação
```

Isso evita transformar uma aplicação pequena em uma arquitetura excessivamente complexa.

---

# 44. Conclusão

A documentação do Horse cumpriu seu papel.

O projeto já utiliza os principais fundamentos necessários para uma API REST pequena em Linux:

```text
Horse
Epoll
Jhonson
Controller
Service
Repository
SQLite
testes
```

Os próximos recursos não devem ser adicionados todos de uma vez.

A próxima etapa recomendada é **observabilidade básica**, começando por logging HTTP, request ID e health check.

Depois disso, o projeto pode continuar evoluindo funcionalmente.

Recursos como autenticação, HTTPS, systemd e reverse proxy entram quando o HorseTeste estiver sendo preparado para funcionar como aplicação real.

Recursos como SSE, WebSocket, streaming, filas, workers, OpenTelemetry e gRPC ficam condicionados a necessidades futuras concretas.

O resultado do estudo não é uma lista de funcionalidades para implementar.

É um **mapa de decisão para o projeto**.
