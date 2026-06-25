# CNAB Validador — Documento de Projeto

| Campo         | Valor                          |
|---------------|-------------------------------|
| **Versão**    | V1                             |
| **Data**      | 2026-03-23                     |
| **Status**    | Aprovado para desenvolvimento  |
| **Autor**     | Arquiteto de Software          |

> **Controle de versões:** Este documento é versionado (V1, V2, …). Nunca sobrescreva uma versão anterior — crie um novo arquivo `PROJETO_V2.md` ao evoluir o projeto, preservando o histórico.

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Objetivos e Escopo do MVP](#2-objetivos-e-escopo-do-mvp)
3. [Requisitos Funcionais](#3-requisitos-funcionais)
4. [Requisitos Não-Funcionais](#4-requisitos-não-funcionais)
5. [Arquitetura do Sistema](#5-arquitetura-do-sistema)
6. [Estrutura de Diretórios](#6-estrutura-de-diretórios)
7. [Backend — Quarkus/Java](#7-backend--quarkusjava)
8. [Frontend — Flutter/Dart](#8-frontend--flutterdart)
9. [Modelo de Dados e Contratos de API](#9-modelo-de-dados-e-contratos-de-api)
10. [Regras de Negócio e Validações](#10-regras-de-negócio-e-validações)
11. [Estrutura dos Layouts YAML](#11-estrutura-dos-layouts-yaml)
12. [Execução da Aplicação](#12-execução-da-aplicação)
13. [Decisões Técnicas](#13-decisões-técnicas)
14. [Fora do Escopo (V1)](#14-fora-do-escopo-v1)

---

## 1. Visão Geral

O **CNAB Validador** é uma aplicação para validação, visualização e correção de arquivos no formato **CNAB** (Centro Nacional de Automação Bancária), com suporte a múltiplos layouts bancários definidos em arquivos YAML.

O sistema permite que o usuário:
- Selecione um layout bancário pré-cadastrado
- Faça upload do arquivo CNAB a ser validado
- Visualize todos os registros e campos do arquivo, com indicação clara de erros
- Corrija os campos inválidos diretamente na interface
- Exporte o arquivo corrigido com o mesmo nome e formato do original

---

## 2. Objetivos e Escopo do MVP

### Objetivos
- Validar arquivos CNAB de remessa e retorno contra layouts YAML pré-carregados
- Apresentar visualmente os campos válidos e inválidos
- Permitir a correção inline dos campos com erro
- Gerar o arquivo corrigido para download

### Escopo do MVP (V1)
- Suporte a layouts do tipo **CNAB400** (linhas de 400 caracteres)
- Suporte a layouts do tipo **CNAB240** (linhas de 240 caracteres)
- Leitura de todos os layouts presentes na pasta `layouts/` do sistema
- Interface web e desktop via Flutter
- Backend stateless (sem banco de dados)
- Execução standalone e via Docker

---

## 3. Requisitos Funcionais

### RF-01 — Seleção de Layout
- A pasta com os layouts deve estar internamente no backend do sistema (`resources/layouts/`)
- O sistema deve listar todas as categorias de layout disponíveis (sub-pastas de `layouts/`)
- O usuário deve selecionar primeiro a categoria (ex: `cobranca_grafica`)
- Após selecionar a categoria, um segundo dropdown deve ser habilitado com os layouts daquela categoria
- Exemplos da primeira categorias: `cobranca_grafica`, `cobranca_bradesco`, `cobranca_itau`, `Compensacao`, etc.
- Exemplo da segunda categoria: (selecionado `cobranca_grafica` na primeira categoria, deve exibir na segunda categoria as seguintes informações: `remessa_cobranca_bradesco_eletronica_tipo_layout_30, remessa_cobranca_bradesco_sem_registro, remessa_cobranca_propria_tipo_layout_40, retorno`.
- Sendo este os arquivos de layout que serão usado para validar o arquivo de upload descrito na RF-02

### RF-02 — Upload e Validação Automática
- O usuário deve ser capaz de importar um arquivo CNAB (qualquer extensão: `.rem`, `.ret`, `.txt`, etc.)
- A validação deve ocorrer **automaticamente** após o upload, sem necessidade de clique adicional
- O sistema deve identificar o tipo de registro de cada linha usando as `rules` do layout selecionado

### RF-03 — Exibição de Informações do Arquivo
Após a validação, deve ser exibido um card com:
- **Título**: "Arquivo Inválido" (em vermelho) ou "Arquivo Válido" (em verde)
- **Nome do arquivo** importado
- **Formato**: `CNAB400`, `CNAB240` ou em branco se não identificado
- **Tipo**: `REMESSA`, `RETORNO` ou em branco se não identificado
- **Total de Linhas**: quantidade de linhas no arquivo
- **Status**: contador de erros totais, atualizado em tempo real conforme correções são feitas

### RF-04 — Visualização dos Registros
- Cada linha do arquivo deve ser exibida como um **bloco expansível/recolhível**
- O cabeçalho do bloco deve mostrar: número da linha + nome do tipo de registro (ex: "Linha 1 — Header-0")
- Dentro do bloco, cada campo deve ocupar uma linha com: posição `[begin:end]`, nome do campo, e valor atual
- Campos inválidos devem ser destacados em **vermelho** com ícone de erro ✗
- Campos válidos devem ser exibidos normalmente (sem destaque negativo)
- **Todos** os campos (válidos ou não) devem ser clicáveis para edição

### RF-05 — Edição de Campos
- Ao clicar em um campo, deve ser aberto um editor inline (TextField)
- O campo deve exibir seu valor atual para edição
- O campo deve exibir um hint indicando para o usuário como deve ser o valor válido do campo
- A re-validação deve ocorrer **localmente no frontend** ao confirmar a edição
- O contador de erros no card de informações deve ser atualizado em tempo real

### RF-06 — Exportação do Arquivo Corrigido
- O botão **Exportar** deve estar **desabilitado** enquanto houver erros (`errorCount > 0`)
- O botão deve ser **habilitado** apenas quando o título exibir "Arquivo Válido"
- Ao clicar em Exportar, o arquivo é enviado ao backend para reconstrução
- O arquivo deve ser reconstruido conforme o layout selecionado previamente
- O usuario deve escolher a pasta que deseja salvar o arquivo
- O novo arquivo deve ser o mesmo enconde do arquivo importado 
- O arquivo baixado deve ter o **mesmo nome** do arquivo original importado
- O arquivo deve ter o **mesmo formato** (mesma extensão e estrutura CNAB)

### RF-07 — Gestão de Layouts
- O sistema deve carregar automaticamente todos os layouts presentes em `resources/layouts/` (classpath)
- A pasta `resources/layouts/` deve respeitar a estrutura: `resources/layouts/<categoria>/<nome_do_layout>.yml`
- Novos layouts são adicionados ao código-fonte e incorporados na compilação (externalização prevista para versões futuras)

---

## 4. Requisitos Não-Funcionais

### RNF-01 — Tecnologia
- **Backend**: Quarkus 3.x com Java 17+
- **Frontend**: Flutter 3.x com Dart
- **Comunicação**: REST HTTP com JSON
- **Parsing de Layout**: SnakeYAML

### RNF-02 — Persistência
- **Sem banco de dados** no MVP (V1)
- O estado da sessão de validação reside **exclusivamente no frontend** (memória)
- Os layouts YAML são carregados do sistema de arquivos na inicialização

### RNF-03 — Execução
- A aplicação deve executar em modo **standalone** (sem Docker)
- A aplicação deve executar via **Docker Compose** com um único comando

### RNF-04 — CORS e Integração
- O backend deve permitir requisições CORS do frontend Flutter (Web)

### RNF-05 — Compatibilidade de Layouts
- O sistema deve suportar todos os layouts presentes em `layouts/` neste projeto
- O sistema deve funcionar para CNAB240 e CNAB400

### RNF-06 — Performance
- A validação de um arquivo de até 10.000 linhas deve completar em menos de 5 segundos
- A interface deve responder à edição de campos em menos de 200ms (re-validação local)

### RNF-06 — Port
- O front-end deve ser executado na porta externa 9085
- O back-end deve ser executado na porta 9084

---

## 5. Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Frontend                          │
│                 (Web / Desktop Linux)                       │
│                                                             │
│  ┌─────────────┐   ┌──────────────┐   ┌─────────────────┐  │
│  │ HomeScreen  │   │Validation    │   │ State (Provider)│  │
│  │             │   │Screen        │   │                 │  │
│  │ - Categoria │   │ - FileInfo   │   │ - ValidationRes │  │
│  │ - Layout    │   │ - RecordBlocks│  │ - errorCount    │  │
│  │ - Upload    │   │ - Exportar   │   │ - editedFields  │  │
│  └──────┬──────┘   └──────┬───────┘   └─────────────────┘  │
│         │                 │                                  │
│         └────────┬────────┘                                  │
│                  │ ApiService (http)                         │
└──────────────────┼──────────────────────────────────────────┘
                   │ HTTP/REST (JSON)
                   │ Port 9084
┌──────────────────┼──────────────────────────────────────────┐
│                  │   Quarkus Backend                        │
│   ┌──────────────▼────────────┐                             │
│   │      REST Resources       │                             │
│   │  LayoutResource           │                             │
│   │  FileResource             │                             │
│   └──────────┬────────────────┘                             │
│              │                                               │
│   ┌──────────▼────────────────────────────────────┐        │
│   │              Services                          │        │
│   │  LayoutService   CnabService                  │        │
│   └──────┬───────────────┬───────────────┬────────┘        │
│          │               │               │                   │
│   ┌──────▼──┐   ┌────────▼──┐   ┌────────▼──┐              │
│   │ Layout  │   │   Cnab    │   │   Cnab    │              │
│   │ Parser  │   │  Parser   │   │ Validator │              │
│   └─────────┘   └───────────┘   └───────────┘              │
│                                                             │
│   resources/layouts/ ←── classpath (compilado no jar)       │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo Principal

```
1. GET /api/layouts
   Frontend → Backend: buscar árvore de categorias/layouts

2. POST /api/validate  (multipart: file + category + layout)
   Frontend → Backend: enviar arquivo CNAB
   Backend:
     a. LayoutParser lê o YAML selecionado
     b. CnabParser lê o arquivo linha a linha
     c. Para cada linha: rules → getSectionName() → key-map → FieldDefinitions
     d. CnabValidator valida cada campo
     e. Retorna JSON completo com registros + campos + status de validação

3. Edição (local no Frontend)
   Usuário edita campo → re-validação local → atualiza errorCount

4. POST /api/export  (body JSON com campos editados)
   Frontend → Backend: enviar estrutura completa com correções
   Backend:
     a. Reconstrói cada linha substituindo campos nas posições corretas
     b. Retorna arquivo como octet-stream com nome original
```

---

## 6. Estrutura de Diretórios

```
cnab-validador/                         ← raiz do projeto
├── PROJETO_V1.md                       ← este documento
├── PLANO_EXECUCAO_V1.md                ← plano de execução
├── README.md                           ← instruções de uso
├── docker-compose.yml                  ← orquestração Docker
│
├── backend/                            ← módulo Quarkus
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
│       ├── main/
│       │   ├── java/br/com/cnabvalidador/
│       │   │   ├── resource/
│       │   │   │   ├── LayoutResource.java
│       │   │   │   └── FileResource.java
│       │   │   ├── service/
│       │   │   │   ├── LayoutService.java
│       │   │   │   └── CnabService.java
│       │   │   ├── parser/
│       │   │   │   ├── LayoutParser.java
│       │   │   │   └── CnabParser.java
│       │   │   ├── validator/
│       │   │   │   └── CnabValidator.java
│       │   │   ├── exporter/
│       │   │   │   └── CnabExporter.java
│       │   │   └── model/
│       │   │       ├── Layout.java
│       │   │       ├── Rules.java
│       │   │       ├── KeyLength.java
│       │   │       ├── RegisterDefinition.java
│       │   │       ├── FieldDefinition.java
│       │   │       ├── FieldType.java
│       │   │       ├── CnabRecord.java
│       │   │       ├── CnabField.java
│       │   │       ├── ValidationResult.java
│       │   │       └── LayoutCategory.java
│       │   └── resources/
|       |       ├── layouts/                            ← layouts YAML (copiados do projeto original)
│       |       |   ├── cobranca_grafica/
│       |       |   │   ├── remessa_cobranca_propria_tipo_layout_40.yml
│       |       |   │   ├── remessa_cobranca_bradesco_eletronica_tipo_layout_30.yml
│       |       |   │   ├── remessa_cobranca_bradesco_sem_registro.yml
│       |       |   │   └── retorno.yml
│       |       |   ├── cobranca_bradesco/
│       |       |   ├── cobranca_itau/
│       |       |   └── ...
│       │       └── application.properties
│       └── test/
│           └── java/br/com/cnabvalidador/
│               ├── parser/LayoutParserTest.java
│               ├── validator/CnabValidatorTest.java
│               └── resource/FileResourceTest.java
│
└── frontend/                           ← módulo Flutter
    ├── pubspec.yaml
    ├── Dockerfile
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── screens/
        │   ├── home_screen.dart
        │   └── validation_screen.dart
        ├── widgets/
        │   ├── file_info_card.dart
        │   ├── record_block.dart
        │   └── field_row.dart
        ├── models/
        │   ├── layout_category.dart
        │   ├── validation_result.dart
        │   ├── cnab_record.dart
        │   └── cnab_field.dart
        ├── services/
        │   └── api_service.dart
        └── providers/
            └── validation_provider.dart
```

---

## 7. Backend — Quarkus/Java

### 7.1 Dependências (pom.xml)

```xml
<dependency>
  <groupId>io.quarkus</groupId>
  <artifactId>quarkus-rest</artifactId>         <!-- JAX-RS REST -->
</dependency>
<dependency>
  <groupId>io.quarkus</groupId>
  <artifactId>quarkus-rest-jackson</artifactId> <!-- JSON -->
</dependency>
<dependency>
  <groupId>io.quarkus</groupId>
  <artifactId>quarkus-smallrye-openapi</artifactId> <!-- Swagger UI -->
</dependency>
<dependency>
  <groupId>org.yaml</groupId>
  <artifactId>snakeyaml</artifactId>            <!-- Parse YAML -->
</dependency>
<dependency>
  <groupId>io.quarkus</groupId>
  <artifactId>quarkus-container-image-docker</artifactId>
</dependency>
```

### 7.2 Configuração (application.properties)

```properties
# Layouts carregados do classpath (resources/layouts/) — compilados no jar
# Externalização via variável de ambiente prevista para versões futuras

# CORS para Flutter Web
quarkus.http.cors=true
quarkus.http.cors.origins=*
quarkus.http.cors.methods=GET,POST,OPTIONS

# Upload: tamanho máximo de arquivo
quarkus.http.limits.max-body-size=50M

# Swagger UI
quarkus.swagger-ui.always-include=true
quarkus.swagger-ui.path=/swagger-ui
```

### 7.3 LayoutParser — Lógica de Parsing YAML

O parser lê o arquivo YAML de layout e popula o objeto `Layout`:

```
Layout
├── seqShow: boolean          ← seq-show
├── rules: Rules
│   └── keyLength: List<KeyLength>  ← rules.column.key-length
│       ├── beginColumn: int
│       └── endColumn: int
├── keyMap: Map<String, String>     ← key-map
└── layoutDefinition: Map<String, RegisterDefinition>  ← layout-definition
    └── RegisterDefinition
        ├── occurrence: int           ← metadata.occurrence
        └── fields: List<FieldDefinition>
            ├── description: String
            ├── begin: int
            ├── end: int
            ├── type: FieldType       ← numerico | texto | alfanumerico
            ├── format: String        ← DDMMYY | DDMMYYYY (nullable)
            └── exceptionValues: List<String>
```

### 7.4 CnabParser — Identificação do Tipo de Registro

Para cada linha do arquivo CNAB:

```
1. Extrai caracteres nas posições definidas em rules.keyLength
2. Concatena → chave (ex: "0", "1", "3P", "3Y01")
3. Busca chave no keyMap
   - Se não encontrar a chave completa: tenta encurtar
     a. Remove caracteres da direita até encontrar
     b. Se não encontrar, remove da esquerda até encontrar
4. Retorna o nome do RegisterDefinition correspondente
5. Para cada campo do RegisterDefinition: extrai substring [begin-1 .. end]
```

### 7.5 CnabValidator — Regras de Validação

```
Para cada CnabField:

1. Verificar se exception-values contém o valor atual
   → Se sim: campo VÁLIDO (ignorar demais validações)

2. Verificar comprimento: valor.length() deve ser igual a (end - begin + 1)
   → Se não: ERRO "Campo deve ter X caracteres"

3. Verificar tipo:
   - numerico:    regex ^\d+$
     → ERRO: "Campo numérico não pode conter letras ou símbolos"
     → Se tem format: validar data (ver item 4)
   - texto:       regex ^[A-Za-z\s]+$
     → ERRO: "Campo texto não pode conter dígitos ou caracteres especiais"
   - alfanumerico: qualquer valor (aceita tudo que não seja vazio)
     → ERRO apenas se campo vazio: "Campo obrigatório"

4. Se type=numerico e format presente:
   - DDMMYY   (6 dígitos): validar data real
   - DDMMYYYY (8 dígitos): validar data real
   → ERRO: "Data inválida. Use o formato DD/MM/AAAA"
```

### 7.6 CnabExporter — Reconstrução do Arquivo

```
Para cada CnabRecord na lista recebida:
  rawLine = linha original do registro (string de 240 ou 400 chars)
  Para cada CnabField editado:
    rawLine = rawLine[0..begin-2] + paddedValue + rawLine[end..]
  Escreve rawLine + "\n" no buffer de saída

Retorna buffer como bytes com Content-Disposition: attachment; filename=<nome_original>
```

**Padding:**
- `numerico` → zeros à esquerda: `String.format("%0Nd", valor)` onde N = `end - begin + 1`
- `texto` e `alfanumerico` → espaços à direita: `String.format("%-Ns", valor)`

---

## 8. Frontend — Flutter/Dart

### 8.1 Dependências (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0               # Requisições HTTP
  provider: ^6.1.0           # Gerenciamento de estado
  file_picker: ^8.0.0        # Seleção de arquivo para upload
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 8.2 Gerenciamento de Estado (ValidationProvider)

```dart
class ValidationProvider extends ChangeNotifier {
  ValidationResult? result;          // Resultado completo da API
  int errorCount = 0;                // Contador de erros atualizado em tempo real
  bool get isValid => errorCount == 0;

  void loadResult(ValidationResult r) { ... }
  void updateField(int lineNumber, int fieldIndex, String newValue) {
    // Atualiza o campo localmente
    // Re-valida usando as mesmas regras do backend
    // Recalcula errorCount
    // notifyListeners()
  }
}
```

### 8.3 Telas

#### HomeScreen
```
┌──────────────────────────────────────────┐
│  CNAB Validador                          │
│                                          │
│  Categoria de Layout                     │
│  [Selecione uma categoria          ▼]    │
│                                          │
│  Layout                                  │
│  [Selecione um layout              ▼]    │
│  (desabilitado até categoria ser selecionada)
│                                          │
│  [  📁 Importar Arquivo CNAB  ]          │
│  (desabilitado até layout ser selecionado)
└──────────────────────────────────────────┘
```

#### ValidationScreen
```
┌──────────────────────────────────────────────────────────────┐
│  ✗ Arquivo Inválido          gr_991_020611.rem               │
│                                                              │
│  Banco: BANCO MATERA SYSTEMS    Empresa: —                   │
│  Data Geração: 02/06/11         Sequencial: 000001           │
│                                                              │
│  [CNAB400]  [REMESSA]  [8 linhas]  [⚠ 3 erros]             │
│                                                              │
│  [  ⬇ Exportar  ]  ← desabilitado enquanto houver erros     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ▼  Linha 1 — Header-0                                       │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [001] Identificação do Registro       0                │  │
│  │ [002] Identificação Arquivo Remessa   1                │  │
│  │ [003:009] Literal Remessa             REMESSA          │  │
│  │ [010:011] Código de Serviço  ✗  00  ← campo c/ erro   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ▶  Linha 2 — Registro-Titulo-1   (recolhido)               │
│  ▶  Linha 3 — Mensagem-Opcional-2 (recolhido)               │
└──────────────────────────────────────────────────────────────┘
```

### 8.4 FieldRow — Comportamento de Edição

```
Estado normal (válido):
  [001:003] Nome do Campo     VALOR_ATUAL     → ao clicar: abre TextField

Estado erro (inválido):
  [001:003] ✗ Nome do Campo   VALOR_ERRADO    → ao clicar: abre TextField (cor vermelha)

Estado edição:
  [001:003] Nome do Campo  [ VALOR_EDITADO ]  [✓] [✗]
                                              Confirmar / Cancelar
  Ao confirmar:
    - Aplica padding automaticamente (zeros/espaços)
    - Re-valida localmente
    - Atualiza provider → notifica FileInfoCard e contador
```

---

## 9. Modelo de Dados e Contratos de API

### 9.1 GET /api/layouts

**Response 200:**
```json
[
  {
    "category": "cobranca_grafica",
    "layouts": [
      "remessa_cobranca_propria_tipo_layout_40",
      "remessa_cobranca_bradesco_eletronica_tipo_layout_30",
      "remessa_cobranca_bradesco_sem_registro",
      "retorno"
    ]
  },
  {
    "category": "cobranca_bradesco",
    "layouts": ["remessa", "retorno"]
  }
]
```

### 9.2 POST /api/validate

**Request:** `multipart/form-data`
| Campo    | Tipo   | Descrição                         |
|----------|--------|-----------------------------------|
| file     | binary | Arquivo CNAB                      |
| category | string | Nome da categoria (pasta)         |
| layout   | string | Nome do layout (sem extensão .yml)|

**Response 200:**
```json
{
  "fileName": "gr_991_020611.rem",
  "status": "INVALID",
  "format": "CNAB400",
  "type": "REMESSA",
  "totalLines": 8,
  "errorCount": 2,
  "records": [
    {
      "lineNumber": 1,
      "recordType": "Header-0",
      "fields": [
        {
          "fieldIndex": 0,
          "description": "Identificação do Registro",
          "begin": 1,
          "end": 1,
          "value": "0",
          "type": "numerico",
          "format": null,
          "exceptionValues": [],
          "valid": true,
          "errorMessage": null
        },
        {
          "fieldIndex": 1,
          "description": "Código de Serviço",
          "begin": 10,
          "end": 11,
          "value": "AB",
          "type": "numerico",
          "format": null,
          "exceptionValues": [],
          "valid": false,
          "errorMessage": "Campo numérico não pode conter letras ou símbolos"
        }
      ]
    }
  ]
}
```

**Response 400:**
```json
{ "error": "Layout não encontrado: cobranca_grafica/retorno" }
```

**Response 422:**
```json
{ "error": "Linha 5 não reconhecida pelo layout. Chave '9X' não encontrada no key-map." }
```

### 9.3 POST /api/export

**Request:** `application/json`
```json
{
  "fileName": "gr_991_020611.rem",
  "records": [
    {
      "lineNumber": 1,
      "fields": [
        { "fieldIndex": 0, "begin": 1, "end": 1, "value": "0" },
        { "fieldIndex": 1, "begin": 10, "end": 11, "value": "01" }
      ]
    }
  ]
}
```

**Response 200:**  
`Content-Type: application/octet-stream`  
`Content-Disposition: attachment; filename="gr_991_020611.rem"`  
Body: bytes do arquivo CNAB reconstruído

---

## 10. Regras de Negócio e Validações

### 10.1 Identificação do Tipo de Registro

O campo `rules.column.key-length` define posições que, ao serem concatenadas, formam uma chave para busca no `key-map`.

**Algoritmo de fallback (encurtamento):**
1. Concatena os caracteres das posições definidas → `chave`
2. Busca `chave` no `key-map`
3. Se não encontrar: remove o último caractere e busca novamente
4. Se não encontrar com tamanho 0: remove o primeiro caractere e reinicia
5. Continua até encontrar ou lançar exceção

**Exemplo:**
```
rules extrai posições: 1
Linha: "0REMESSA..."
Chave: "0"
key-map: { "0": "Header-0", "1": "Registro-Titulo-1", "9": "Trailer-9" }
Resultado: "Header-0" ✓
```

### 10.2 Tabela de Validações por Tipo

| Tipo         | Regex           | Vazio | Padding        | Formato       |
|--------------|-----------------|-------|----------------|---------------|
| `numerico`   | `^\d+$`         | erro  | zeros à esq.   | DDMMYY/DDMMYYYY |
| `texto`      | `^[A-Za-z\s]+$` | erro  | espaços à dir. | —             |
| `alfanumerico` | `.*` (qualquer) | erro  | espaços à dir. | —             |

### 10.3 Validação de Datas

| Formato    | Comprimento | Regra                                   |
|------------|-------------|----------------------------------------|
| `DDMMYY`   | 6 dígitos   | Dia 01-31, Mês 01-12, Ano 00-99        |
| `DDMMYYYY` | 8 dígitos   | Dia 01-31, Mês 01-12, Ano 0000-9999    |

### 10.4 Exception Values

Se um campo define `exception-values`, qualquer valor que esteja nessa lista é considerado **automaticamente válido**, independente do tipo, comprimento ou formato.

```yaml
exception-values:
  - "00000000"   # Data vazia é aceita
  - "00"         # Código vazio é aceito
```

### 10.5 Identificação de Formato e Tipo do Arquivo

| Campo do arquivo | Layout YAML              | Inferência          |
|-----------------|--------------------------|---------------------|
| Formato CNAB    | Comprimento da linha     | 240 → CNAB240, 400 → CNAB400 |
| Tipo Remessa    | Nome do layout ou campo  | Contém "remessa" → REMESSA   |
| Tipo Retorno    | Nome do layout ou campo  | Contém "retorno"  → RETORNO  |

---

## 11. Estrutura dos Layouts YAML

### 11.1 Anatomia Completa de um Layout

```yaml
seq-show: false                      # false = agrupa por tipo | true = mostra em sequência

rules:
  column:
    key-length:
      - begin-column: 1              # posição (1-based) para extrair o identificador
        end-column: 1

key-map:
  "0": Header-0                      # chave → nome do RegisterDefinition
  "1": Registro-Titulo-1
  "9": Trailer-9

layout-definition:
  Header-0:                          # nome deve bater com key-map
    - metadata:
        occurrence: 1                # quantas vezes este registro pode ocorrer

    - fields:
      - description: Identificacao do Registro
        begin: 1                     # posição inicial (1-based)
        end: 1                       # posição final (inclusive)
        type: numerico               # numerico | texto | alfanumerico

      - description: Data de Gravacao
        begin: 95
        end: 100
        type: numerico
        format: DDMMYY               # validação adicional de data

      - description: Data do Protocolo
        begin: 459
        end: 466
        type: numerico
        format: DDMMYYYY
        exception-values:            # valores sempre aceitos
          - "00000000"
```

### 11.2 Organização da Pasta de Layouts

Os layouts residem **dentro do projeto backend**, em `src/main/resources/layouts/`, e são compilados no jar.

```
src/main/resources/
└── layouts/
    └── <categoria>/                     # nome da categoria (pasta)
        └── <nome_layout>.yml            # arquivo de layout
```

A **categoria** é o nome da pasta (ex: `cobranca_grafica`).  
O **nome do layout** é o nome do arquivo sem extensão (ex: `remessa_cobranca_propria_tipo_layout_40`).

---

## 12. Execução da Aplicação

### 12.1 Standalone (Desenvolvimento)

**Pré-requisitos:**
- Java 17+
- Maven 3.8+
- Flutter 3.x + Dart

```bash
# Backend (modo dev com hot-reload)
cd backend
./mvnw quarkus:dev
# API disponível em: http://localhost:9084
# Swagger UI: http://localhost:9084/swagger-ui

# Frontend (web)
cd frontend
flutter pub get
flutter run -d chrome --web-port 9085

# Frontend (desktop Linux)
cd frontend
flutter pub get
flutter run -d linux
```

### 12.2 Docker Compose

**Pré-requisitos:**
- Docker 20+
- Docker Compose v2+

```bash
# Na raiz do projeto
docker-compose up --build

# Acessar frontend: http://localhost:9085
# Acessar API:      http://localhost:9084
# Swagger UI:       http://localhost:9084/swagger-ui
```

**docker-compose.yml:**
```yaml
version: "3.9"
services:
  backend:
    build: ./backend
    ports:
      - "9084:9084"
    # layouts compilados no jar (resources/layouts/) — sem volume necessário

  frontend:
    build: ./frontend
    ports:
      - "9085:9085"
    depends_on:
      - backend
    environment:
      - API_BASE_URL=http://localhost:9084
```

### 12.3 Dockerfiles

**backend/Dockerfile** (multi-stage):
```dockerfile
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package -Dquarkus.package.type=uber-jar -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /deployments
COPY --from=build /app/target/*-runner.jar app.jar
EXPOSE 9084
CMD ["java", "-jar", "app.jar"]
```

**frontend/Dockerfile** (multi-stage):
```dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml .
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 9085
```

---

## 13. Decisões Técnicas

| Decisão                         | Escolha                  | Justificativa                                                    |
|---------------------------------|--------------------------|------------------------------------------------------------------|
| Backend                         | Quarkus / Java 17        | Requisito do projeto. Startup rápido, ideal para containers.     |
| Frontend                        | Flutter / Dart           | Requisito do projeto. Suporte nativo web + desktop.              |
| Banco de dados                  | Nenhum (MVP)             | Simplicidade. Estado no frontend, layouts em arquivos.           |
| Parse de YAML                   | SnakeYAML                | Biblioteca padrão Java para YAML, suporte completo.              |
| Estado no frontend              | Provider                 | Simples, reativo, sem overhead de Redux/Riverpod para MVP.       |
| Validação no frontend           | Lógica replicada do back | Evita round-trip para re-validação inline (performance UX).      |
| Upload de arquivo               | Multipart form-data      | Padrão HTTP para transferência de arquivos binários.             |
| Export de arquivo               | JSON com campos editados | Backend reconstrói o arquivo garantindo posicionamento correto.  |
| Encoding do arquivo CNAB        | ISO-8859-1 (Latin-1)     | Padrão histórico dos bancos brasileiros para CNAB.               |

---

## 14. Fora do Escopo (V1)

Os itens abaixo **não fazem parte desta versão** e poderão ser incorporados em versões futuras:

- Autenticação e controle de acesso de usuários
- Banco de dados para histórico de validações
- Upload de novos layouts pela interface (apenas via sistema de arquivos)
- Validação de regras de negócio específicas por banco (ex: dígito verificador)
- Suporte a outros formatos além de CNAB240 e CNAB400
- Processamento em lote de múltiplos arquivos simultaneamente
- Notificações ou relatórios por e-mail
- API pública documentada para integração com terceiros
- Internacionalização (i18n) além do português
- Modo offline completo (PWA)
