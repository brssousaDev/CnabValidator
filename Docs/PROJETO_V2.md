# PROJETO CNAB Validador - V2

**Versão:** 2.0  
**Data:** Março de 2026  
**Status:** Desenvolvimento  

---

## 1. Visão Geral do Projeto

O **CNAB Validador** é uma aplicação multiplataforma desenvolvida em **Flutter** (frontend) e **Quarkus** (backend) para validação, visualização e correção de arquivos CNAB (Câmara de Compensação e Liquidação) de bancos brasileiros.

### Objetivo Principal
Permitir que usuários:
1. **Importem** arquivos CNAB em diferentes formatos (CNAB240, CNAB400, etc.)
2. **Validem** os arquivos contra layouts específicos de cada banco
3. **Visualizem** cada registro e campo de forma clara
4. **Editem** campos com erro para corrigi-los
5. **Exportem** o arquivo corrigido com a mesma estrutura e encoding original

### Diferenciais
- ✅ Suporte a múltiplos layouts (Itaú, Bradesco, Santander, Matera, Caixa, etc.)
- ✅ Validação em tempo real ao editar campos
- ✅ Feedback visual imediato de erros
- ✅ Preservação de dados originais para export correto
- ✅ Interface intuitiva com Flutter Material Design

---

## 2. Arquitetura Geral

### 2.1 Stack Tecnológico

**RNF-01 — Tecnologia:**
- **Backend**: Quarkus 3.x com Java 17+
  - REST API com endpoints para validação e exportação
  - Parsing YAML para layouts
  - Processamento eficiente de arquivos grandes
  
- **Frontend**: Flutter 3.x com Dart
  - Aplicação Web responsiva
  - Provider pattern para gerenciamento de estado
  - Integração HTTP com backend
  
- **Comunicação**: REST HTTP com JSON
  - Content-Type: application/json
  - CORS habilitado para requisições do frontend
  
- **Parsing de Layout**: SnakeYAML
  - Leitura de arquivos `.yml` dos layouts
  - Estrutura hierárquica de definições

### 2.2 Estrutura de Diretórios

```
cnab-validador/
├── backend/                    # Aplicação Quarkus
│   ├── src/main/java/         # Código-fonte Java
│   │   ├── br/com/cnabvalidador/
│   │   │   ├── resource/       # REST Endpoints
│   │   │   ├── service/        # Lógica de negócio
│   │   │   ├── parser/         # Parser YAML e CNAB
│   │   │   ├── validator/      # Validação de campos
│   │   │   ├── exporter/       # Exportação de arquivos
│   │   │   └── model/          # Modelos de dados
│   ├── src/main/resources/     # Recursos
│   │   └── layouts/            # Layouts YAML organizados por categoria
│   └── pom.xml                 # Maven configuration
│
├── frontend/                   # Aplicação Flutter
│   ├── lib/
│   │   ├── screens/            # Telas (Home, Validation)
│   │   ├── widgets/            # Componentes reutilizáveis
│   │   ├── models/             # Modelos de dados Dart
│   │   ├── providers/          # Gerencimento de estado
│   │   ├── services/           # Integração com API
│   │   └── main.dart           # Entrada da aplicação
│   └── pubspec.yaml            # Dependências Flutter
│
├── layout/                     # Layouts CNAB por categoria
│   ├── cobranca_matera/        # Banco Matera
│   ├── cobranca_itau/          # Banco Itaú
│   ├── cobranca_bradesco/      # Banco Bradesco
│   └── ...                     # Outros bancos
│
├── Docs/
│   ├── PROJETO_V1.md           # Especificação V1
│   ├── PROJETO_V2.md           # Especificação V2 (este arquivo)
│   ├── LOGICA_VALIDACAO.md     # Tabelas de validação detalhadas
│   ├── MATERA-1-1-201189.rem   # Arquivo de exemplo
│   └── images/                 # Capturas de tela
│
└── docker-compose.yml          # Orquestração de containers
```

---

## 3. Fluxo de Funcionamento

### 3.1 Fluxo Principal: Validação e Edição

```
┌──────────────────────────────────────────────────────────────────┐
│ FLUXO PRINCIPAL: IMPORTAR → VALIDAR → EDITAR → EXPORTAR          │
└──────────────────────────────────────────────────────────────────┘

1. IMPORTAR ARQUIVO
   ↓
   [Frontend] Usuário clica em "Importar Arquivo"
   → Abre seletor de arquivos (.rem, .ret, .txt)
   → Seleciona categoria (ex: "cobranca_matera")
   → Seleciona layout (ex: "400remessa")
   ↓
   
2. VALIDAR NO BACKEND
   ↓
   [Frontend] Envia arquivo + categoria + layout para POST /api/validate
   [Backend] Recebe upload multipart
   → Carrega layout do classpath (resources/layouts/cobranca_matera/400remessa.yml)
   → Lê linhas do arquivo em ISO-8859-1
   → Para cada linha:
      • Extrai chave (ex: primeiro caractere "0", "1", "9")
      • Procura section no key-map (ex: "0" → "header")
      • Se encontrado, cria CnabRecord com todos os campos
      • Se não encontrado, pula a linha
   → Valida cada campo contra tipo (numerico, texto, alfanumerico)
   → Conta erros por campo
   → Retorna ValidationResult com records e errorCount
   ↓
   
3. EXIBIR RESULTADO
   ↓
   [Frontend] Recebe ValidationResult
   → Se errorCount == 0: mostra "Arquivo Válido" em verde
   → Se errorCount > 0: mostra "Arquivo Inválido" em vermelho
   → Exibe lista de registros para edição (se houver)
   ↓
   
4. EDITAR REGISTROS
   ↓
   [Frontend] Usuário clica em campo para editar
   → Mostra campo em modo de edição
   → Ao sair do campo, valida localmente
   → Se tiver erro: mostra mensagem em vermelho
   → Se corrigir: remove mensagem de erro
   → Atualiza errorCount local
   ↓
   
5. EXPORTAR ARQUIVO
   ↓
   [Frontend] Usuário clica em "Exportar"
   → Envia ValidationResult (com edições) para POST /api/export
   [Backend] Reconstrói arquivo:
      • Para cada record editado:
         - Pega original line do campo originalLines
         - Substitui valores dos campos que foram editados
         - Respeita posições begin/end de cada campo
      • Retorna arquivo binário completo
   [Frontend] Captura arquivo binário
   → Cria Blob
   → Dispara download automático
   → Arquivo salvo com nome original e encoding ISO-8859-1
   ↓
   ✅ FIM
```

### 3.2 Endpoints REST

#### POST /api/validate
**Importar e validar arquivo CNAB**

Request:
```
Content-Type: multipart/form-data

file: <binary file>
category: "cobranca_matera"
layout: "400remessa"
```

Response: 200 OK
```json
{
  "fileName": "MATERA-1-1-201189.rem",
  "status": "VALID",
  "format": "CNAB400",
  "type": "REMESSA",
  "totalLines": 3,
  "errorCount": 0,
  "records": [
    {
      "lineNumber": 1,
      "recordType": "header",
      "fields": [
        {
          "fieldIndex": 1,
          "description": "Tipo de registro",
          "begin": 1,
          "end": 1,
          "value": "0",
          "type": "numerico",
          "valid": true,
          "errorMessage": null
        },
        ...
      ]
    },
    ...
  ]
}
```

#### POST /api/export
**Exportar arquivo corrigido**

Request:
```json
{
  "fileName": "MATERA-1-1-201189.rem",
  "records": [ ... ],
  "format": "CNAB400",
  ...
}
```

Response: 200 OK
```
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="MATERA-1-1-201189.rem"

[arquivo binário em ISO-8859-1]
```

#### GET /api/layouts
**Listar categorias e layouts disponíveis**

Response: 200 OK
```json
[
  {
    "category": "cobranca_matera",
    "layouts": ["400remessa", "400retorno", "240RemessaRetorno"]
  },
  {
    "category": "cobranca_itau",
    "layouts": ["remessa", "retorno"]
  },
  ...
]
```

#### GET /api/health
**Health check**

Response: 200 OK
```json
{
  "status": "UP"
}
```

---

## 4. Requisitos Funcionais (RF)

### RF-01 — Seleção de Arquivo
- ✅ Usuário clica em botão "Importar Arquivo"
- ✅ Abre seletor de arquivos (filtra .rem, .ret, .txt)
- ✅ Retorna arquivo selecionado para upload

### RF-02 — Seleção de Categoria e Layout
- ✅ Após selecionar arquivo, mostrar dropdown de categorias
- ✅ Categorias carregadas dinamicamente do backend (/api/layouts)
- ✅ Ao selecionar categoria, mostrar layouts disponíveis
- ✅ Layouts carregados do backend conforme categoria
- ✅ Ambos os campos são obrigatórios para continuar

### RF-03 — Validação do Arquivo
- ✅ Enviar arquivo + categoria + layout ao backend
- ✅ Backend processa arquivo conforme layout selecionado
- ✅ Para cada linha do arquivo:
  - Extrai chave (conforme rules do layout)
  - Procura section correspondente no key-map
  - Se encontrado, cria CnabRecord
  - Se não encontrado, pula linha
- ✅ Para cada campo:
  - Valida tipo (numerico, texto, alfanumerico)
  - Valida comprimento (begin/end)
  - Valida valores excetuados (exception-values)
  - Valida datas (se format = DDMMYY ou DDMMYYYY)
- ✅ Retorna resultado com lista de registros e contagem de erros

### RF-04 — Exibição de Resultado
- ✅ Exibir card de informações:
  - Nome do arquivo
  - Formato (CNAB240 ou CNAB400)
  - Tipo (REMESSA ou RETORNO)
  - Total de linhas
  - Status (Válido/Inválido em verde/vermelho)
  - Contagem de erros
- ✅ Se houver registros: exibir "Visualização de Registros"
  - Lista cada registro com tipo (header, detalhe, trailer)
  - Mostra contadores e separadores visuais
- ✅ Se houver erros:
  - Destaque visual em vermelho para campos com erro
  - Mensagem de erro específica para cada campo
- ✅ Se arquivo válido (0 erros):
  - Mostrar card verde com "Arquivo Válido"
  - Permitir edição dos campos

### RF-05 — Edição de Registros
- ✅ Usuário clica em um campo para editar
- ✅ Campo entra em modo de edição
- ✅ Ao sair do campo (blur/unfocus):
  - Validação local conforme tipo e comprimento
  - Se erro: mostra mensagem em vermelho
  - Se ok: limpa mensagem
- ✅ Atualiza contagem de erros do documento
- ✅ Mantém dados não editados com seus valores originais
- ✅ Preserva campos válidos sem alteração

### RF-06 — Exportação do Arquivo Corrigido
- ✅ Botão "Exportar" fica desabilitado enquanto há erros
- ✅ Botão habilitado apenas quando errorCount == 0
- ✅ Ao clicar, arquivo é enviado ao backend para reconstrução
- ✅ Backend reconstrói arquivo respeitando:
  - Posições originais dos campos (begin/end)
  - Edições do usuário
  - Valores não-editados do original
  - Padding (zeros para numerico, espaços para texto)
- ✅ Usuário recebe download do arquivo:
  - Nome original preservado
  - Encoding ISO-8859-1
  - Mesmo formato (CNAB240 ou CNAB400)
  - Mesma estrutura de registros

### RF-07 — Gestão de Layouts
- ✅ Sistema carrega automaticamente todos os layouts de `resources/layouts/`
- ✅ Estrutura: `resources/layouts/<categoria>/<nome_layout>.yml`
- ✅ Novos layouts adicionados ao código-fonte
- ✅ Compilação inclui layouts automaticamente
- ✅ Externalização prevista para versões futuras

---

## 5. Lógica Detalhada de Validação

### 5.1 Tabela Completa de Validação - Tipo NUMERICO

| Situação | Resultado | isTypeOk | isLengthOk | Cor | Mensagem |
|----------|-----------|----------|------------|-----|----------|
| **Vazio** (`""`) | ❌ | false | - | 🔴 vermelho | "Este campo é do tipo numérico e não pode possuir letras ou símbolos." |
| **Só espaços** (`"   "`) | ❌ | false | falha | 🔴 vermelho | "Este campo é do tipo numérico..." + "Este campo é uma data..." (se formato) |
| **Números válidos** (`"12345"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Com letras** (`"123A5"`) | ❌ | false | passa | 🔴 vermelho | "Este campo é do tipo numérico..." |
| **Com símbolos** (`"123-45"`) | ❌ | false | passa | 🔴 vermelho | "Este campo é do tipo numérico..." |
| **Data DDMMYYYY inválida** (`"99999999"`) | ❌ | false | passa | 🔴 vermelho | "Este campo é uma data, certifique-se que esteja no formato DDMMYYYY com uma data válida" |
| **Data DDMMYYYY válida** (`"31121999"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Data DDMMYY inválida** (`"999999"`) | ❌ | false | passa | 🔴 vermelho | "Este campo é uma data, certifique-se que esteja no formato DDMMYY com uma data válida" |
| **Data DDMMYY válida** (`"311299"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Comprimento errado** (`"123"` em 5 dígitos) | ❌ | true | falha | 🔴 vermelho | "Este campo deve ter 5 caracteres e atualmente possui 3 caracteres" |

**Validação Numérica:**
```java
// 1. Verificar se vazio
if (value.isEmpty() || value.trim().isEmpty()) {
    return "Este campo é do tipo numérico e não pode possuir letras ou símbolos.";
}

// 2. Verificar se contém apenas dígitos
if (!value.matches("^\\d+$")) {
    return "Este campo é do tipo numérico e não pode possuir letras ou símbolos.";
}

// 3. Se tem format de data, validar data
if (format != null && (format.equals("DDMMYY") || format.equals("DDMMYYYY"))) {
    if (!isValidDate(value, format)) {
        return "Este campo é uma data, certifique-se que esteja no formato " + 
               format + " com uma data válida";
    }
}

// 4. Verificar comprimento exato
if (value.length() != expectedLength) {
    return "Este campo deve ter " + expectedLength + " caracteres e atualmente possui " + 
           value.length() + " caracteres";
}

return null; // Válido
```

### 5.2 Tabela Completa de Validação - Tipo TEXTO

| Situação | Resultado | isTypeOk | isLengthOk | Cor | Mensagem |
|----------|-----------|----------|------------|-----|----------|
| **Vazio** (`""`) | ❌ | false | - | 🔴 vermelho | "Este campo é do tipo texto e não pode possuir dígitos ou caracteres especiais" |
| **Só espaços** (`"   "`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Apenas letras** (`"ABCDE"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Letras minúsculas** (`"abcde"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Letras + espaços** (`"NOME COMPLETO"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Com números** (`"123ABC"`) | ❌ | false | passa | 🔴 vermelho | "Este campo é do tipo texto e não pode possuir dígitos ou caracteres especiais" |
| **Com símbolos** (`"ABC@123"`) | ❌ | false | passa | 🔴 vermelho | "Este campo é do tipo texto e não pode possuir dígitos ou caracteres especiais" |
| **Comprimento errado** (`"ABC"` em 5 caracteres) | ❌ | true | falha | 🔴 vermelho | "Este campo deve ter 5 caracteres e atualmente possui 3 caracteres" |

**Validação Textual:**
```java
// 1. Verificar se vazio
if (value.isEmpty()) {
    return "Este campo é do tipo texto e não pode possuir dígitos ou caracteres especiais";
}

// 2. Espaços em branco são válidos em texto
if (value.trim().isEmpty()) {
    // Aceita se só tem espaços
    return null;
}

// 3. Verificar se contém apenas letras e espaços
if (!value.matches("^[A-Za-z\\s]+$")) {
    return "Este campo é do tipo texto e não pode possuir dígitos ou caracteres especiais";
}

// 4. Verificar comprimento exato
if (value.length() != expectedLength) {
    return "Este campo deve ter " + expectedLength + " caracteres e atualmente possui " + 
           value.length() + " caracteres";
}

return null; // Válido
```

### 5.3 Tabela Completa de Validação - Tipo ALFANUMERICO

| Situação | Resultado | isTypeOk | isLengthOk | Cor | Mensagem |
|----------|-----------|----------|------------|-----|----------|
| **Vazio** (`""`) | ❌ | false | - | 🔴 vermelho | "Informe um texto qualquer" |
| **Só espaços** (`"   "`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Apenas letras** (`"ABCDE"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Apenas números** (`"12345"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Letras + números** (`"ABC123"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Especiais** (`"ABC@123"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Pontuação** (`"ABC-123.45"`) | ✅ | true | passa | ⚪ branco | Nenhum |
| **Comprimento errado** (`"ABC"` em 5 caracteres) | ❌ | true | falha | 🔴 vermelho | "Este campo deve ter 5 caracteres e atualmente possui 3 caracteres" |

**Validação Alfanumérica:**
```java
// 1. Verificar se vazio
if (value.isEmpty()) {
    return "Informe um texto qualquer";
}

// 2. Alfanumérico aceita QUALQUER COISA se não estiver vazio
// Incluindo espaços, números, letras, símbolos, pontuação

// 3. Verificar comprimento exato
if (value.length() != expectedLength) {
    return "Este campo deve ter " + expectedLength + " caracteres e atualmente possui " + 
           value.length() + " caracteres";
}

return null; // Válido
```

### 5.4 Validações Especiais

#### Exception-Values
Alguns campos têm valores excepcionados que são considerados válidos mesmo que não respeitem as regras de tipo:

```yaml
field:
  description: "Status do registro"
  type: numerico
  exception-values: ["00", "01", "09", "XX"]
```

Se o valor estiver em `exception-values`, é considerado válido independente de tipo ou comprimento.

#### Validação de Datas
Para campos com `format: DDMMYY` ou `format: DDMMYYYY`:

```java
private boolean isValidDate(String dateStr, String format) {
    try {
        int day, month, year;
        
        if (format.equals("DDMMYY")) {
            day = Integer.parseInt(dateStr.substring(0, 2));
            month = Integer.parseInt(dateStr.substring(2, 4));
            year = Integer.parseInt(dateStr.substring(4, 6)) + 2000; // YY → YYYY
        } else if (format.equals("DDMMYYYY")) {
            day = Integer.parseInt(dateStr.substring(0, 2));
            month = Integer.parseInt(dateStr.substring(2, 4));
            year = Integer.parseInt(dateStr.substring(4, 8));
        }
        
        // Validar mês
        if (month < 1 || month > 12) return false;
        
        // Validar dia conforme o mês
        int[] daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        
        // Ajustar para ano bissexto (fevereiro)
        if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
            daysInMonth[1] = 29;
        }
        
        if (day < 1 || day > daysInMonth[month - 1]) return false;
        
        return true;
    } catch (Exception e) {
        return false;
    }
}
```

---

## 6. Requisitos Não-Funcionais (RNF)

### RNF-01 — Tecnologia
- ✅ **Backend**: Quarkus 3.x com Java 17+
- ✅ **Frontend**: Flutter 3.x com Dart
- ✅ **Comunicação**: REST HTTP com JSON
- ✅ **Parsing de Layout**: SnakeYAML

### RNF-02 — Persistência
- ✅ **Sem banco de dados** no MVP (V1/V2)
- ✅ Estado da sessão reside **exclusivamente no frontend** (memória)
- ✅ Layouts YAML carregados do sistema de arquivos na inicialização

### RNF-03 — Execução
- ✅ Aplicação executa em modo **standalone** (sem Docker)
  - Comando: `java -jar backend/target/quarkus-app/quarkus-run.jar`
  - Frontend: `flutter run -d chrome`
  
- ✅ Aplicação executa via **Docker Compose** com um único comando
  - Comando: `docker-compose up`

### RNF-04 — CORS e Integração
- ✅ Backend permite requisições CORS do frontend Flutter (Web)
- ✅ Headers CORS configurados em FileResource

### RNF-05 — Compatibilidade de Layouts
- ✅ Sistema suporta todos os layouts presentes em `resources/layouts/`
- ✅ Sistema funciona para CNAB240 e CNAB400
- ✅ Suporte a REMESSA e RETORNO
- ✅ Suporte a múltiplos bancos (Matera, Itaú, Bradesco, Santander, Caixa, etc.)

### RNF-06 — Performance
- ✅ Validação de arquivo até 10.000 linhas completa em menos de 5 segundos
- ✅ Interface responde à edição de campos em menos de 200ms (re-validação local)

### RNF-07 — Ports
- ✅ **Frontend**: Porta externa **9085**
  - http://localhost:9085
  
- ✅ **Backend**: Porta interna **9084**
  - http://localhost:9084/api

---

## 7. Modelo de Dados

### 7.1 Estrutura de Layouts YAML

```yaml
rules:
  column:
    key-length:
      - begin-column: 1        # Começa na coluna 1 (1-based)
        end-column: 1          # Termina na coluna 1 (extrai 1 caractere)

key-map:
  0: header                    # Chave "0" → tipo "header"
  1: detail-register           # Chave "1" → tipo "detail-register"
  9: trailer                   # Chave "9" → tipo "trailer"

layout-definition:
  header:                      # Definição de campos do header
    - metadata:
        occurrence: 1          # Ocorre 1 vez no arquivo
    - fields:
        - description: "Tipo de registro"
          begin: 1
          end: 1
          type: numerico
        - description: "Código remessa"
          begin: 2
          end: 2
          type: numerico
        # ... mais campos ...

  detail-register:
    - metadata:
        occurrence: "1:*"      # Ocorre 1 ou mais vezes
    - fields:
        - description: "Tipo de registro"
          begin: 1
          end: 1
          type: numerico
        # ... mais campos ...

  trailer:
    - metadata:
        occurrence: 1
    - fields:
        - description: "Tipo de registro"
          begin: 1
          end: 1
          type: numerico
        # ... mais campos ...
```

### 7.2 Estrutura de Classes Java

```java
// Modelo de dados para um registro CNAB
public class CnabRecord {
    private int lineNumber;           // Número da linha no arquivo
    private String recordType;        // Tipo (header, detail-register, trailer)
    private List<CnabField> fields;   // Lista de campos do registro
}

// Um campo individual
public class CnabField {
    private int fieldIndex;           // Índice do campo (1, 2, 3, ...)
    private String description;       // Descrição do campo
    private int begin;                // Coluna de início (1-based)
    private int end;                  // Coluna de término (1-based)
    private String value;             // Valor extraído da linha
    private String type;              // Tipo (numerico, texto, alfanumerico)
    private String format;            // Formato especial (DDMMYY, DDMMYYYY, etc)
    private List<String> exceptionValues; // Valores excepcionados
    private boolean valid;            // É válido?
    private String errorMessage;      // Mensagem de erro (se inválido)
}

// Resultado da validação
public class ValidationResult {
    private String fileName;          // Nome do arquivo original
    private String status;            // Status (VALID, INVALID)
    private String format;            // Formato (CNAB240, CNAB400)
    private String type;              // Tipo (REMESSA, RETORNO)
    private int totalLines;           // Total de linhas do arquivo
    private int errorCount;           // Contagem de campos com erro
    private List<CnabRecord> records; // Lista de registros validados
    private Map<Integer, String> originalLines; // Linhas originais para export
}
```

### 7.3 Estrutura Dart (Flutter)

```dart
// Espelha a estrutura Java
class CnabRecord {
  final int lineNumber;
  final String recordType;
  final List<CnabField> fields;
  
  // Métodos fromJson/toJson para serialização
}

class CnabField {
  final int fieldIndex;
  final String description;
  final int begin, end;
  final String value, type;
  final String? format;
  final List<String>? exceptionValues;
  final bool valid;
  final String? errorMessage;
  
  // Métodos fromJson/toJson para serialização
}

class ValidationResult {
  final String fileName;
  final String status;
  final String? format;
  final String? type;
  final int totalLines;
  final int errorCount;
  final List<CnabRecord> records;
  
  // Métodos fromJson/toJson para serialização
}
```

---

## 8. Fluxo de Desenvolvimento

### 8.1 Setup Local

#### Pré-requisitos
- Java 17+
- Maven 3.8+
- Flutter 3.x
- Dart 3.x

#### Backend
```bash
cd backend
mvn clean package
java -jar target/quarkus-app/quarkus-run.jar
# Backend disponível em http://localhost:9084
```

#### Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome
# Frontend disponível em http://localhost:9085
```

### 8.2 Processo de Validação

1. **Parse YAML**: LayoutParser lê arquivo `.yml` do layout
2. **Extração de Chaves**: CnabParser extrai chave conforme rules do layout
3. **Lookup de Seção**: Procura chave no key-map para descobrir tipo de registro
4. **Criação de Records**: Para cada linha reconhecida, cria CnabRecord
5. **Validação de Campos**: CnabValidator valida cada campo contra tipos
6. **Contagem de Erros**: Conta campos inválidos
7. **Retorno de Resultado**: Retorna ValidationResult com todos os dados

### 8.3 Mudanças da V1 para V2

| Aspecto | V1 | V2 |
|---------|----|----|
| **Documentação** | Requisitos básicos | + Tabelas de validação completas |
| **Lógica de Validação** | Implementada | Documentada em detalhe |
| **Tratamento de Null** | Faltante | ✅ Adicionado em CnabParser |
| **Export Feature** | Parcial | ✅ Completo com original lines |
| **Records Vazios** | 🐛 Bug | ✅ Corrigido |
| **Edição de Registros** | ✅ Disponível | ✅ + Validação local |

---

## 9. Troubleshooting

### Problema: "Nenhum registro foi processado"
**Causa:** Layout não foi carregado ou chave não foi encontrada
**Solução:** 
- Verificar se layout existe em `resources/layouts/<categoria>/<layout>.yml`
- Verificar se `key-map` está presente no YAML
- Garantir que primeiros caracteres da linha fazem match com key-map

### Problema: Arquivo válido mas mostra erros
**Causa:** Validação muito rigorosa ou exception-values não configuradas
**Solução:**
- Adicionar exception-values para valores especiais
- Revisar regras de tipo (numerico, texto, alfanumerico)
- Verificar se campos têm comprimento exato

### Problema: Export retorna arquivo vazio
**Causa:** originalLines não foi armazenado
**Solução:**
- Garantir que CnabService.validate() popula originalLines
- Verificar que ValidationResult.originalLines não é null

---

## 10. Roadmap Futuro


---

## 11. Conclusão

O CNAB Validador V2 consolida a funcionalidade completa de validação, edição e exportação de arquivos CNAB com documentação detalhada de lógica de validação. A aplicação oferece uma experiência intuitiva e eficiente para bancos e empresas processarem arquivos CNAB em múltiplos formatos.

**Status**: ✅ Pronto para produção (MVP V2)

