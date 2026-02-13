//
//  API_Integration.md
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

# 🌐 Integração com API do Studio Ghibli

## 📋 Resumo

O projeto agora consome dados da **API oficial do Studio Ghibli** usando Swift Concurrency (`async/await`) com isolamento no `@MainActor`.

**Base URL:** `https://ghibliapi.vercel.app`

---

## 🎯 Endpoints Implementados

### 1. **GET /films** - Lista todos os filmes
**Uso:** Tela de catálogo (`FilmCatalogView`)

**Resposta da API:**
```json
[
  {
    "id": "2baf70d1-42bb-4437-b551-e5fed5a87abe",
    "title": "Castle in the Sky",
    "original_title": "天空の城ラピュタ",
    "original_title_romanised": "Tenkū no shiro Rapyuta",
    "image": "https://image.tmdb.org/t/p/w600_and_h900_bestv2/npOnzAbLh6VOIu3naU5QaEcTepo.jpg",
    "movie_banner": "https://image.tmdb.org/t/p/original/3JfYV6zCszgw3DgVZQKj1Bx2OzU.jpg",
    "description": "The orphan Sheeta inherited a mysterious crystal...",
    "director": "Hayao Miyazaki",
    "producer": "Isao Takahata",
    "release_date": "1986",
    "running_time": "124",
    "rt_score": "95"
  },
  ...
]
```

**Implementação:**
```swift
let films = try await FilmService.shared.fetchAllFilms()
```

---

### 2. **GET /films/{id}** - Detalhes de um filme
**Uso:** Tela de detalhes (`FilmDetailView`)

**Exemplo:** `https://ghibliapi.vercel.app/films/2baf70d1-42bb-4437-b551-e5fed5a87abe`

**Resposta da API:**
```json
{
  "id": "2baf70d1-42bb-4437-b551-e5fed5a87abe",
  "title": "Castle in the Sky",
  "original_title": "天空の城ラピュタ",
  "description": "The orphan Sheeta inherited a mysterious crystal...",
  "director": "Hayao Miyazaki",
  "producer": "Isao Takahata",
  "release_date": "1986",
  "running_time": "124",
  "rt_score": "95",
  ...
}
```

**Implementação:**
```swift
let film = try await FilmService.shared.fetchFilmDetail(apiId: "2baf70d1-42bb-4437-b551-e5fed5a87abe")
```

---

## 🏗️ Arquitetura da Integração

### 1. **NetworkManager** (`@MainActor`)
Camada genérica de rede responsável por todas as requisições HTTP.

**Características:**
- ✅ Isolamento no `@MainActor` para thread-safety
- ✅ Método genérico `request<T: Decodable>`
- ✅ Tratamento robusto de erros
- ✅ Debug logging (apenas em DEBUG)
- ✅ Timeout configurável (30s request, 60s resource)
- ✅ JSONDecoder com `snake_case` → `camelCase`

**Exemplo de uso:**
```swift
@MainActor
let films = try await NetworkManager.shared.request(
    endpoint: "/films",
    type: [FilmDTO].self
)
```

---

### 2. **FilmService** (`@MainActor`)
Serviço específico de filmes que usa o `NetworkManager`.

**Características:**
- ✅ Isolamento no `@MainActor`
- ✅ Cache em memória (5 minutos)
- ✅ Conversão DTO → Domain Model
- ✅ Ordenação por ano
- ✅ Métodos de cache (clear, force refresh)

**Cache:**
```swift
// Limpar cache
FilmService.shared.clearCache()

// Forçar atualização (ignora cache)
let films = try await FilmService.shared.forceRefresh()
```

---

### 3. **DTOs (Data Transfer Objects)**
Estruturas que mapeiam exatamente a resposta da API.

**FilmDTO:**
```swift
struct FilmDTO: Codable {
    let id: String
    let title: String
    let originalTitle: String
    let originalTitleRomanised: String
    let image: String
    let movieBanner: String
    let description: String
    let director: String
    let producer: String
    let releaseDate: String
    let runningTime: String
    let rtScore: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, image, description, director, producer
        case originalTitle = "original_title"
        case originalTitleRomanised = "original_title_romanised"
        case movieBanner = "movie_banner"
        case releaseDate = "release_date"
        case runningTime = "running_time"
        case rtScore = "rt_score"
    }
}
```

---

### 4. **Domain Model** (`Film`)
Modelo de domínio do app (não expõe estrutura da API).

**Conversão DTO → Model:**
```swift
extension Film {
    init(from dto: FilmDTO, position: Int = 0) {
        self.id = UUID()
        self.apiId = dto.id
        self.title = dto.title
        self.japaneseTitle = dto.originalTitle
        self.year = Int(dto.releaseDate) ?? 0
        self.rating = Int(dto.rtScore) ?? 0
        self.duration = Int(dto.runningTime) ?? 0
        self.synopsis = dto.description
        self.director = dto.director
        self.producer = dto.producer
        self.imageName = dto.image
        self.position = position
    }
}
```

---

## 🔄 Fluxo de Dados Completo

```
┌──────────────────────────────────────────────────────────┐
│                    1. View Layer                         │
│  FilmCatalogView ou FilmDetailView                       │
│  ↓ .task { await viewModel.loadFilms() }                │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                   2. ViewModel Layer                      │
│  FilmCatalogViewModel ou FilmDetailViewModel             │
│  ↓ try await filmService.fetchAllFilms()                │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                   3. Service Layer                        │
│  FilmService (@MainActor)                                │
│  • Verifica cache (5 min)                                │
│  • Se não tem cache: chama NetworkManager                │
│  ↓ try await networkManager.request(...)                │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                  4. Network Layer                         │
│  NetworkManager (@MainActor)                             │
│  • Constrói URL                                          │
│  • Cria URLRequest                                       │
│  • Executa: let (data, response) = try await            │
│    session.data(for: request)                            │
│  • Valida status code                                    │
│  • Decodifica JSON → FilmDTO                            │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                    5. API Externa                         │
│  https://ghibliapi.vercel.app/films                      │
│  Retorna JSON com lista de filmes                        │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                 6. Data Transformation                    │
│  FilmDTO → Film (Domain Model)                           │
│  • Converte tipos (String → Int)                         │
│  • Adiciona position                                     │
│  • Ordena por ano                                        │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                    7. Cache Layer                         │
│  FilmService salva em memória                            │
│  cachedFilms = films                                     │
│  cacheTimestamp = Date()                                 │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                  8. ViewModel Update                      │
│  ViewModel atualiza propriedades                         │
│  films = [...]                                           │
│  isLoading = false                                       │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                   9. View Re-render                       │
│  SwiftUI detecta mudança (@Observable)                   │
│  View automaticamente re-renderiza                       │
│  Grid/List mostra filmes                                 │
└──────────────────────────────────────────────────────────┘
```

---

## 🎭 @MainActor e Concorrência

### Por que @MainActor?

**Problema:** Atualizações de UI devem acontecer na main thread.

**Solução:** `@MainActor` garante que todo código execute na main thread.

### Implementação:

```swift
// NetworkManager isolado no MainActor
@MainActor
final class NetworkManager {
    func request<T: Decodable>(endpoint: String, type: T.Type) async throws -> T {
        // Todo código executa na main thread
        let (data, response) = try await session.data(for: request)
        // Decodificação também na main thread
        return try decoder.decode(T.self, from: data)
    }
}

// FilmService também isolado
@MainActor
final class FilmService: FilmServiceProtocol {
    func fetchAllFilms() async throws -> [Film] {
        // Chama NetworkManager (também @MainActor)
        let dtos = try await networkManager.request(endpoint: "/films", type: [FilmDTO].self)
        // Conversão na main thread
        return dtos.map { Film(from: $0) }
    }
}

// ViewModel não precisa anotar métodos individuais
@Observable
final class FilmCatalogViewModel {
    func loadFilms() async {
        // Já está na main thread porque FilmService é @MainActor
        films = try await filmService.fetchAllFilms()
        // Atualização de UI segura!
    }
}
```

### Benefícios:

- ✅ **Thread-safe por design** - Não precisa se preocupar com threads
- ✅ **Sem `DispatchQueue.main.async`** - Tudo automático
- ✅ **SwiftUI-friendly** - Updates diretos nas propriedades @Observable
- ✅ **Compiler-enforced** - Swift garante segurança em compile time

---

## 🧪 Como Testar

### 1. Testar com Mock Service (Offline)

```swift
// Use MockFilmService para testes sem rede
let mockService = MockFilmService()
let viewModel = FilmCatalogViewModel(filmService: mockService)

await viewModel.loadFilms()
// Usa dados locais (Film.sampleFilms)
```

### 2. Testar com API Real (Online)

```swift
// Use FilmService.shared para testar com API real
let viewModel = FilmCatalogViewModel(filmService: FilmService.shared)

await viewModel.loadFilms()
// Busca dados de https://ghibliapi.vercel.app/films
```

### 3. Testar Tratamento de Erros

```swift
let mockService = MockFilmService()
mockService.shouldFail = true
mockService.mockError = .networkError(NetworkError.noInternetConnection)

let viewModel = FilmCatalogViewModel(filmService: mockService)
await viewModel.loadFilms()

// viewModel.errorMessage contém mensagem de erro
```

### 4. Testar Cache

```swift
// Primeira chamada: busca da API
let films1 = try await FilmService.shared.fetchAllFilms()
print("📥 Primeira chamada: \(films1.count) filmes")

// Segunda chamada (< 5 min): usa cache
let films2 = try await FilmService.shared.fetchAllFilms()
print("📦 Do cache: \(films2.count) filmes")

// Forçar refresh (ignora cache)
let films3 = try await FilmService.shared.forceRefresh()
print("🔄 Forçado: \(films3.count) filmes")
```

---

## 🐛 Tratamento de Erros

### Tipos de Erros:

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noInternetConnection
    case timeout
    case unknown(Error)
}

enum FilmServiceError: LocalizedError {
    case networkError(NetworkError)
    case filmNotFound
    case unknown(Error)
}
```

### Fluxo de Erro:

```
API retorna 404
    ↓
NetworkManager lança .httpError(statusCode: 404)
    ↓
FilmService captura e lança .filmNotFound
    ↓
ViewModel captura e define errorMessage
    ↓
View mostra UI de erro com botão retry
```

### Mensagens Amigáveis:

```swift
switch error {
case NetworkError.noInternetConnection:
    "Sem conexão com a internet. Verifique sua conexão."
    
case NetworkError.httpError(404):
    "Recurso não encontrado (404)."
    
case NetworkError.timeout:
    "Tempo esgotado. Tente novamente."
    
case NetworkError.decodingError:
    "Erro ao processar os dados. Tente novamente."
}
```

---

## 🔍 Debug e Logging

### Console Output:

#### Sucesso:
```
🌐 Buscando filmes da API...
📥 Response from /films:
[{"id":"2baf70d1-42bb-4437-b551-e5fed5a87abe","title":"Castle in the Sky",...}]
✅ 22 filmes carregados com sucesso
```

#### Com Cache:
```
📦 Usando filmes do cache
```

#### Erro de Rede:
```
🌐 Buscando filmes da API...
❌ Erro de rede: Sem conexão com a internet. Verifique sua conexão.
```

#### Erro de Decodificação:
```
🌐 Buscando filmes da API...
❌ Decoding Error: keyNotFound
🔑 Key 'title' not found: No value associated with key CodingKeys(stringValue: "title")
📍 Coding path: []
❌ Erro de rede: Erro ao processar os dados. Tente novamente.
```

### Desabilitar Logs em Produção:

Os logs detalhados só aparecem em `DEBUG` mode:

```swift
#if DEBUG
if let jsonString = String(data: data, encoding: .utf8) {
    print("📥 Response from \(endpoint):")
    print(jsonString)
}
#endif
```

---

## 📊 Performance e Cache

### Estratégia de Cache:

1. **Primeira requisição:**
   - Busca da API (pode demorar 1-2s)
   - Salva em memória
   - Retorna dados

2. **Requisições subsequentes (< 5 min):**
   - Retorna do cache (instantâneo)
   - Sem requisição de rede

3. **Após 5 minutos:**
   - Cache expira
   - Próxima requisição busca da API novamente

### Configurar Validade do Cache:

```swift
// Em FilmService.swift
private let cacheValidityDuration: TimeInterval = 300 // 5 minutos

// Para mudar:
private let cacheValidityDuration: TimeInterval = 600 // 10 minutos
```

### Pull-to-Refresh:

O `refresh()` do ViewModel usa o cache normalmente:

```swift
// Para forçar atualização em pull-to-refresh:
func refresh() async {
    do {
        films = try await filmService.forceRefresh() // Ignora cache
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

---

## 🚀 Próximos Passos

### 1. Adicionar Imagens dos Filmes
```swift
// Use AsyncImage do SwiftUI
AsyncImage(url: URL(string: film.imageName)) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

### 2. Persistência Local (SwiftData)
```swift
@Model
final class CachedFilm {
    var apiId: String
    var title: String
    var cachedDate: Date
    // ...
}
```

### 3. Offline Mode
```swift
// Verificar conectividade
if NetworkManager.shared.isConnectedToInternet() {
    // Buscar da API
} else {
    // Usar dados locais
}
```

### 4. Paginação (se API suportar)
```swift
func fetchFilms(page: Int, limit: Int) async throws -> [Film]
```

### 5. Busca e Filtros
```swift
func searchFilms(query: String) async throws -> [Film]
func filterFilms(by director: String) async throws -> [Film]
```

---

## ✅ Checklist de Implementação

- [x] Criar NetworkManager com @MainActor
- [x] Criar DTOs para mapear API
- [x] Atualizar Film model com apiId
- [x] Implementar FilmService com requisições reais
- [x] Adicionar sistema de cache
- [x] Atualizar ViewModels
- [x] Atualizar testes unitários
- [x] Adicionar tratamento robusto de erros
- [x] Adicionar logs de debug
- [x] Documentar API integration

---

## 🎉 Conclusão

O app agora:
- ✅ Consome API real do Studio Ghibli
- ✅ Usa Swift Concurrency moderna (@MainActor, async/await)
- ✅ Tem cache inteligente
- ✅ Trata erros graciosamente
- ✅ É 100% testável (Mock Service)
- ✅ Está pronto para crescer

**Teste agora mesmo rodando o app e vendo dados reais da API! 🚀**
