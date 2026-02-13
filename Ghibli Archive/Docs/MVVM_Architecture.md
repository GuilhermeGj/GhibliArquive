//
//  MVVM_Architecture.md
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

# Arquitetura MVVM - Ghibli Archive

Este projeto segue a arquitetura **MVVM (Model-View-ViewModel)** com uma **camada de serviço** para gerenciamento de dados.

## Estrutura de Camadas

### 📦 Model (Modelo)
**Arquivo:** `Film.swift`

Representa a entidade de dados do filme. É uma estrutura simples que contém:
- Propriedades do filme (título, ano, diretor, etc.)
- Dados de exemplo (`sampleFilms`)
- Conformidade com `Identifiable` e `Hashable`

```swift
struct Film: Identifiable, Hashable {
    let id: UUID
    let title: String
    let japaneseTitle: String
    // ... outras propriedades
}
```

---

### 🔧 Service (Serviço)
**Arquivo:** `FilmService.swift`

Camada responsável por buscar e gerenciar dados. Separa a lógica de acesso a dados da lógica de apresentação.

**Características:**
- Pattern Singleton para acesso global
- Protocol `FilmServiceProtocol` para facilitar testes
- Simula operações assíncronas (preparado para futuras chamadas de API)
- Inclui `MockFilmService` para testes e previews

```swift
protocol FilmServiceProtocol {
    func fetchAllFilms() async throws -> [Film]
    func fetchFilmDetail(filmId: UUID) async throws -> Film?
    func getTotalFilmsCount() -> Int
}
```

**Métodos principais:**
- `fetchAllFilms()`: Busca todos os filmes
- `fetchFilmDetail(filmId:)`: Busca detalhes de um filme específico
- `getTotalFilmsCount()`: Retorna o total de filmes

---

### 🧠 ViewModel (View Model)

#### FilmCatalogViewModel
**Arquivo:** `FilmCatalogViewModel.swift`

Gerencia o estado e lógica de negócio da tela de catálogo.

**Responsabilidades:**
- Carregar lista de filmes
- Gerenciar estado de loading
- Tratar erros
- Fornecer dados formatados para a View

**Propriedades observáveis:**
```swift
private(set) var films: [Film] = []
private(set) var isLoading = false
private(set) var errorMessage: String?
```

**Métodos principais:**
```swift
func loadFilms() async  // Carrega filmes
func refresh() async    // Recarrega dados
func clearError()       // Limpa erros
```

#### FilmDetailViewModel
**Arquivo:** `FilmDetailViewModel.swift`

Gerencia o estado e lógica de negócio da tela de detalhes.

**Responsabilidades:**
- Carregar detalhes do filme
- Formatar dados (duração, rating)
- Gerenciar estado de loading
- Tratar erros

**Propriedades observáveis:**
```swift
private(set) var film: Film
private(set) var isLoading = false
private(set) var errorMessage: String?
private(set) var isDetailLoaded = false
```

**Computed Properties:**
```swift
var formattedDuration: String  // "2h 5min" ou "89min"
var formattedRating: String    // "95/100"
```

---

### 🎨 View (Visão)

#### FilmCatalogView
**Arquivo:** `FilmCatalogView.swift`

Interface da tela de catálogo de filmes.

**Responsabilidades:**
- Exibir lista de filmes em grid
- Mostrar indicadores de loading
- Exibir mensagens de erro
- Navegar para detalhes do filme

**Estado:**
```swift
@State private var viewModel = FilmCatalogViewModel()
```

**Ciclo de vida:**
```swift
.task {
    await viewModel.loadFilms()  // Carrega dados ao aparecer
}
```

#### FilmDetailView
**Arquivo:** `FilmDetailView.swift`

Interface da tela de detalhes do filme.

**Responsabilidades:**
- Exibir informações detalhadas do filme
- Mostrar indicadores de loading
- Exibir mensagens de erro
- Permitir voltar para o catálogo

**Inicialização:**
```swift
init(film: Film) {
    self._viewModel = State(initialValue: FilmDetailViewModel(film: film))
}
```

---

## Fluxo de Dados

```
┌─────────┐
│  View   │ ──(ação)──> ┌──────────┐
│         │             │ViewModel │
│         │ <─(dados)── │          │
└─────────┘             └──────────┘
                             │
                        (busca dados)
                             │
                             ▼
                        ┌─────────┐
                        │ Service │
                        │         │
                        └─────────┘
                             │
                        (retorna)
                             │
                             ▼
                        ┌─────────┐
                        │  Model  │
                        └─────────┘
```

### Exemplo de Fluxo:

1. **View** aparece na tela
2. `.task` chama `viewModel.loadFilms()`
3. **ViewModel** marca `isLoading = true`
4. **ViewModel** chama `filmService.fetchAllFilms()`
5. **Service** busca os dados (simula rede)
6. **Service** retorna `[Film]`
7. **ViewModel** atualiza `films` e `isLoading = false`
8. **View** automaticamente re-renderiza com os novos dados

---

## Benefícios da Arquitetura

### ✅ Separação de Responsabilidades
Cada camada tem uma função clara e específica.

### ✅ Testabilidade
- ViewModels podem ser testados sem UI
- Service pode ser mockado com `MockFilmService`
- Lógica de negócio isolada

### ✅ Reusabilidade
- Service pode ser usado por múltiplos ViewModels
- ViewModels podem ser reutilizados em diferentes Views

### ✅ Manutenibilidade
- Código organizado e fácil de encontrar
- Mudanças em uma camada não afetam as outras
- Fácil adicionar novas features

### ✅ Escalabilidade
- Preparado para adicionar API real
- Fácil adicionar cache, persistência
- Pode crescer sem refatoração massiva

---

## Preparado para o Futuro

### 🌐 Integração com API Real
O `FilmService` está preparado para integração com APIs reais:

```swift
func fetchAllFilms() async throws -> [Film] {
    // Substituir por:
    let url = URL(string: "https://api.ghibli.com/films")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Film].self, from: data)
}
```

### 💾 Cache e Persistência
Pode adicionar camada de cache no Service:

```swift
final class FilmService: FilmServiceProtocol {
    private var cachedFilms: [Film]?
    
    func fetchAllFilms() async throws -> [Film] {
        if let cached = cachedFilms {
            return cached
        }
        // Buscar da rede...
    }
}
```

### 🧪 Testes Unitários
Com a arquitetura atual, é fácil adicionar testes:

```swift
import Testing

@Test func filmCatalogLoadsFilms() async throws {
    let mockService = MockFilmService()
    let viewModel = FilmCatalogViewModel(filmService: mockService)
    
    await viewModel.loadFilms()
    
    #expect(!viewModel.films.isEmpty)
    #expect(!viewModel.isLoading)
}
```

---

## Exemplo de Uso

### Criar nova feature com MVVM:

1. **Criar Model** (se necessário)
2. **Adicionar método no Service**
3. **Criar ViewModel**
4. **Criar View que usa o ViewModel**

### Exemplo: Adicionar busca de filmes

```swift
// 1. Service
protocol FilmServiceProtocol {
    func searchFilms(query: String) async throws -> [Film]
}

// 2. ViewModel
@Observable
class FilmSearchViewModel {
    private(set) var results: [Film] = []
    private let service: FilmServiceProtocol
    
    func search(query: String) async {
        results = try await service.searchFilms(query: query)
    }
}

// 3. View
struct FilmSearchView: View {
    @State private var viewModel = FilmSearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        List(viewModel.results) { film in
            Text(film.title)
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) {
            Task {
                await viewModel.search(query: searchText)
            }
        }
    }
}
```

---

## Convenções do Projeto

### Nomenclatura
- **Models**: Substantivo singular (`Film`, `Director`)
- **Services**: Substantivo + "Service" (`FilmService`, `DirectorService`)
- **ViewModels**: Nome da View + "ViewModel" (`FilmCatalogViewModel`)
- **Views**: Substantivo + "View" (`FilmCatalogView`)

### Organização de Arquivos
```
Ghibli Archive/
├── Models/
│   └── Film.swift
├── Services/
│   └── FilmService.swift
├── ViewModels/
│   ├── FilmCatalogViewModel.swift
│   └── FilmDetailViewModel.swift
└── Views/
    ├── FilmCatalogView.swift
    └── FilmDetailView.swift
```

### Boas Práticas
- ViewModels sempre `@Observable` (ou `@MainActor` se necessário)
- Services sempre protocol-based para testabilidade
- Views não devem ter lógica de negócio
- Sempre usar `async/await` para operações assíncronas
- Tratar erros adequadamente em cada camada

---

## Conclusão

Esta arquitetura MVVM com camada de serviço proporciona:
- **Código limpo e organizado**
- **Facilidade de manutenção**
- **Preparação para crescimento**
- **Testabilidade completa**
- **Separação clara de responsabilidades**

O projeto está pronto para evoluir de dados estáticos para uma API real, adicionar cache, persistência local, e qualquer outra feature necessária! 🚀
