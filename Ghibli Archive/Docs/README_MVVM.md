//
//  README_MVVM.md
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

# 🎬 Ghibli Archive - Refatoração MVVM

## 📋 Resumo das Mudanças

O projeto **Ghibli Archive** foi refatorado para seguir a arquitetura **MVVM (Model-View-ViewModel)** com uma **camada de serviço dedicada**.

---

## 🆕 Novos Arquivos Criados

### 1. **FilmService.swift** 🔧
Camada de serviço responsável por buscar dados dos filmes.

**Principais características:**
- ✅ Protocol-based (`FilmServiceProtocol`)
- ✅ Singleton pattern para acesso global
- ✅ Operações assíncronas com `async/await`
- ✅ Inclui `MockFilmService` para testes
- ✅ Preparado para futura integração com API real

**Métodos:**
```swift
func fetchAllFilms() async throws -> [Film]
func fetchFilmDetail(filmId: UUID) async throws -> Film?
func getTotalFilmsCount() -> Int
```

---

### 2. **FilmCatalogViewModel.swift** 🧠
ViewModel para a tela de catálogo de filmes.

**Responsabilidades:**
- Gerenciar lista de filmes
- Controlar estado de carregamento
- Lidar com erros
- Fornecer dados formatados

**Propriedades observáveis:**
```swift
private(set) var films: [Film] = []
private(set) var isLoading = false
private(set) var errorMessage: String?
var totalFilmsCount: Int
```

**Métodos:**
```swift
func loadFilms() async
func refresh() async
func clearError()
```

---

### 3. **FilmDetailViewModel.swift** 🧠
ViewModel para a tela de detalhes do filme.

**Responsabilidades:**
- Gerenciar dados do filme
- Formatar informações (duração, rating)
- Controlar estado de carregamento
- Lidar com erros

**Propriedades observáveis:**
```swift
private(set) var film: Film
private(set) var isLoading = false
private(set) var errorMessage: String?
private(set) var isDetailLoaded = false
```

**Computed Properties:**
```swift
var formattedDuration: String  // Ex: "2h 5min"
var formattedRating: String    // Ex: "95/100"
```

---

### 4. **FilmCatalogViewModelTests.swift** 🧪
Testes unitários completos usando Swift Testing framework.

**Cobertura de testes:**
- ✅ Carregamento de filmes (sucesso e falha)
- ✅ Refresh de dados
- ✅ Tratamento de erros
- ✅ Estados de loading
- ✅ Testes de integração

---

### 5. **MVVM_Architecture.md** 📚
Documentação completa da arquitetura com:
- Explicação de cada camada
- Diagramas de fluxo de dados
- Exemplos de uso
- Boas práticas
- Guia para futuras implementações

---

## 🔄 Arquivos Modificados

### **FilmCatalogView.swift**

**Antes:**
```swift
@State private var films = Film.sampleFilms
```

**Depois:**
```swift
@State private var viewModel = FilmCatalogViewModel()

// Adicionado:
.task {
    await viewModel.loadFilms()
}

// Novo: Indicador de loading
if viewModel.isLoading {
    ProgressView()
}

// Novo: Tratamento de erro com retry
if let errorMessage = viewModel.errorMessage {
    VStack {
        Text(errorMessage)
        Button("Tentar Novamente") {
            Task { await viewModel.refresh() }
        }
    }
}
```

---

### **FilmDetailView.swift**

**Antes:**
```swift
let film: Film
```

**Depois:**
```swift
@State private var viewModel: FilmDetailViewModel

init(film: Film) {
    self._viewModel = State(initialValue: FilmDetailViewModel(film: film))
}

// Adicionado:
.task {
    await viewModel.loadFilmDetails()
}

// Novo: Indicadores de loading e erro
if viewModel.isLoading {
    ProgressView()
}

if let errorMessage = viewModel.errorMessage {
    // UI de erro com retry
}
```

---

## 📊 Comparação: Antes vs Depois

### **Antes (Sem MVVM)**

```
┌─────────────┐
│    View     │
│             │
│ - Lógica    │
│ - UI        │
│ - Dados     │
└─────────────┘
```

**Problemas:**
- ❌ View com muita responsabilidade
- ❌ Difícil de testar
- ❌ Lógica misturada com UI
- ❌ Dados hardcoded na View

---

### **Depois (Com MVVM + Service)**

```
┌──────────┐
│   View   │  ← Apenas UI
└────┬─────┘
     │
┌────▼─────────┐
│  ViewModel   │  ← Lógica e Estado
└────┬─────────┘
     │
┌────▼─────────┐
│   Service    │  ← Busca de Dados
└────┬─────────┘
     │
┌────▼─────────┐
│    Model     │  ← Entidades
└──────────────┘
```

**Benefícios:**
- ✅ Separação clara de responsabilidades
- ✅ 100% testável
- ✅ Fácil manutenção
- ✅ Preparado para crescer
- ✅ Reutilizável

---

## 🎯 Melhorias Implementadas

### 1. **Testabilidade** 🧪
```swift
// Agora é possível testar facilmente:
@Test func loadFilmsSuccess() async throws {
    let mockService = MockFilmService()
    let viewModel = FilmCatalogViewModel(filmService: mockService)
    await viewModel.loadFilms()
    #expect(!viewModel.films.isEmpty)
}
```

### 2. **Estados de Loading** ⏳
```swift
// Views agora mostram feedback visual
if viewModel.isLoading {
    ProgressView()
}
```

### 3. **Tratamento de Erros** ⚠️
```swift
// Erros são tratados graciosamente
if let errorMessage = viewModel.errorMessage {
    Text(errorMessage)
    Button("Tentar Novamente") { 
        await viewModel.refresh() 
    }
}
```

### 4. **Formatação de Dados** 📝
```swift
// ViewModels fornecem dados formatados
viewModel.formattedDuration  // "2h 5min"
viewModel.formattedRating    // "95/100"
```

### 5. **Injeção de Dependências** 💉
```swift
// Service pode ser mockado para testes
init(filmService: FilmServiceProtocol = FilmService.shared)
```

---

## 🚀 Próximos Passos (Possíveis Evoluções)

### 1. **Integração com API Real**
```swift
func fetchAllFilms() async throws -> [Film] {
    let url = URL(string: "https://ghibliapi.herokuapp.com/films")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Film].self, from: data)
}
```

### 2. **Cache de Dados**
```swift
final class FilmService {
    private var cache: [Film]?
    private var cacheDate: Date?
    
    func fetchAllFilms() async throws -> [Film] {
        if let cached = cache, cacheDate?.timeIntervalSinceNow ?? 0 < 300 {
            return cached
        }
        // Buscar dados...
    }
}
```

### 3. **Persistência Local**
```swift
import SwiftData

@Model
final class CachedFilm {
    var id: UUID
    var title: String
    // ...
}
```

### 4. **Paginação**
```swift
func loadMoreFilms(page: Int) async throws -> [Film]
```

### 5. **Busca e Filtros**
```swift
func searchFilms(query: String) async throws -> [Film]
func filterFilms(by year: Int) async throws -> [Film]
```

---

## 📁 Nova Estrutura de Pastas (Recomendada)

```
Ghibli Archive/
├── App/
│   └── Ghibli_ArchiveApp.swift
│
├── Models/
│   └── Film.swift
│
├── Services/
│   └── FilmService.swift
│
├── ViewModels/
│   ├── FilmCatalogViewModel.swift
│   └── FilmDetailViewModel.swift
│
├── Views/
│   ├── FilmCatalogView.swift
│   ├── FilmDetailView.swift
│   └── ContentView.swift
│
├── Coordinators/
│   └── AppCoordinator.swift
│
└── Tests/
    └── FilmCatalogViewModelTests.swift
```

---

## 🧪 Como Rodar os Testes

### Xcode:
1. Pressione `Cmd + U` ou
2. Product → Test
3. Os testes usam o novo Swift Testing framework

### Terminal:
```bash
swift test
```

---

## 📖 Aprendizados Principais

### 1. **@Observable vs @ObservableObject**
```swift
// ✅ Novo (iOS 17+): Mais simples
@Observable
class FilmCatalogViewModel { }

// ❌ Antigo: Mais verboso
class FilmCatalogViewModel: ObservableObject {
    @Published var films: [Film] = []
}
```

### 2. **Async/Await vs Combine**
```swift
// ✅ Usado: Mais legível
func loadFilms() async { }

// ❌ Alternativa: Mais complexo
func loadFilms() -> AnyPublisher<[Film], Error> { }
```

### 3. **Protocol-Oriented Programming**
```swift
// ✅ Service como protocol permite mockagem
protocol FilmServiceProtocol { }
class FilmService: FilmServiceProtocol { }
class MockFilmService: FilmServiceProtocol { }
```

---

## 🎓 Recursos de Referência

- [Apple Documentation: MVVM](https://developer.apple.com/documentation/)
- [Swift by Sundell: Async/Await](https://www.swiftbysundell.com/)
- [Swift Testing Framework](https://developer.apple.com/xcode/swift-testing/)
- [WWDC Sessions sobre SwiftUI Architecture](https://developer.apple.com/wwdc/)

---

## ✅ Checklist de Implementação

- [x] Criar camada de Service
- [x] Criar ViewModels para cada tela
- [x] Refatorar Views para usar ViewModels
- [x] Adicionar estados de loading
- [x] Adicionar tratamento de erros
- [x] Implementar retry em caso de erro
- [x] Criar testes unitários
- [x] Documentar arquitetura
- [x] Preparar para futuras integrações

---

## 🎉 Conclusão

A refatoração para MVVM foi concluída com sucesso! O projeto agora está:

- ✅ **Bem estruturado** - Código organizado e fácil de navegar
- ✅ **Testável** - 100% de cobertura possível nos ViewModels
- ✅ **Escalável** - Preparado para crescer sem refatoração massiva
- ✅ **Manutenível** - Mudanças isoladas em camadas específicas
- ✅ **Profissional** - Seguindo as melhores práticas do mercado

O código está pronto para produção e futuras expansões! 🚀

---

**Desenvolvido com ❤️ usando Swift e SwiftUI**
