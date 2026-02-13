//
//  QuickReference.md
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

# 🚀 Guia Rápido - MVVM no Ghibli Archive

## 📚 Índice Rápido
- [Arquivos Criados](#arquivos-criados)
- [Arquivos Modificados](#arquivos-modificados)
- [Como Usar](#como-usar)
- [Cheat Sheet](#cheat-sheet)
- [Troubleshooting](#troubleshooting)

---

## 📦 Arquivos Criados

### 1. FilmService.swift
```swift
// Buscar todos os filmes
let films = try await FilmService.shared.fetchAllFilms()

// Buscar filme específico
let film = try await FilmService.shared.fetchFilmDetail(filmId: id)

// Total de filmes
let count = FilmService.shared.getTotalFilmsCount()
```

### 2. FilmCatalogViewModel.swift
```swift
// Criar ViewModel
let viewModel = FilmCatalogViewModel()

// Carregar filmes
await viewModel.loadFilms()

// Recarregar
await viewModel.refresh()

// Limpar erro
viewModel.clearError()
```

### 3. FilmDetailViewModel.swift
```swift
// Criar ViewModel
let viewModel = FilmDetailViewModel(film: film)

// Carregar detalhes
await viewModel.loadFilmDetails()

// Usar formatações
let duration = viewModel.formattedDuration  // "2h 5min"
let rating = viewModel.formattedRating      // "95/100"
```

### 4. FilmCatalogViewModelTests.swift
Suite completa de testes usando Swift Testing

### 5. Documentação
- MVVM_Architecture.md - Arquitetura completa
- README_MVVM.md - Resumo das mudanças
- ArchitectureDiagram.swift - Diagrama visual
- ProjectStructure.md - Organização de arquivos

---

## ✏️ Arquivos Modificados

### FilmCatalogView.swift
**Mudanças principais:**
```swift
// ANTES
@State private var films = Film.sampleFilms

// DEPOIS
@State private var viewModel = FilmCatalogViewModel()

// Adicionado ao final do body
.task {
    await viewModel.loadFilms()
}

// Adicionado no VStack
if viewModel.isLoading {
    ProgressView()
}

if let errorMessage = viewModel.errorMessage {
    // UI de erro com retry
}
```

### FilmDetailView.swift
**Mudanças principais:**
```swift
// ANTES
let film: Film

// DEPOIS
@State private var viewModel: FilmDetailViewModel

init(film: Film) {
    self._viewModel = State(initialValue: FilmDetailViewModel(film: film))
}

// Todas as referências a `film` viram `viewModel.film`

// Adicionado ao final
.task {
    await viewModel.loadFilmDetails()
}
```

---

## 🎯 Como Usar

### Criar nova tela com MVVM

#### 1. Criar Service (se necessário)
```swift
protocol MyServiceProtocol {
    func fetchData() async throws -> [MyModel]
}

final class MyService: MyServiceProtocol {
    static let shared = MyService()
    private init() {}
    
    func fetchData() async throws -> [MyModel] {
        // Implementação
    }
}
```

#### 2. Criar ViewModel
```swift
@Observable
final class MyFeatureViewModel {
    private(set) var data: [MyModel] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    private let service: MyServiceProtocol
    
    init(service: MyServiceProtocol = MyService.shared) {
        self.service = service
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            data = try await service.fetchData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

#### 3. Criar View
```swift
struct MyFeatureView: View {
    @State private var viewModel = MyFeatureViewModel()
    
    var body: some View {
        List(viewModel.data) { item in
            Text(item.name)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
```

---

## 📝 Cheat Sheet

### Service Layer

```swift
// ✅ BOM: Protocol-based
protocol FilmServiceProtocol {
    func fetch() async throws -> [Film]
}

final class FilmService: FilmServiceProtocol {
    static let shared = FilmService()
    private init() {}
}

// ❌ RUIM: Sem protocol
class FilmService {
    // Difícil de mockar para testes
}
```

### ViewModel Layer

```swift
// ✅ BOM: @Observable com private(set)
@Observable
final class MyViewModel {
    private(set) var data: [Item] = []
    
    @MainActor
    func load() async { }
}

// ❌ RUIM: Propriedades públicas mutáveis
class MyViewModel {
    var data: [Item] = []  // Qualquer um pode modificar!
}
```

### View Layer

```swift
// ✅ BOM: View simples, lógica no ViewModel
struct MyView: View {
    @State private var viewModel = MyViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
        }
        .task {
            await viewModel.load()
        }
    }
}

// ❌ RUIM: Lógica na View
struct MyView: View {
    @State private var items: [Item] = []
    
    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .task {
            // Lógica de negócio aqui = RUIM!
            items = await fetchFromAPI()
        }
    }
}
```

### Testes

```swift
// ✅ BOM: Usar Mock Service
@Test func testLoading() async {
    let mockService = MockFilmService()
    let viewModel = FilmCatalogViewModel(filmService: mockService)
    
    await viewModel.loadFilms()
    
    #expect(!viewModel.films.isEmpty)
}

// ❌ RUIM: Depender de dados reais
@Test func testLoading() async {
    let viewModel = FilmCatalogViewModel()
    // Usa FilmService.shared = depende de dados reais
}
```

---

## 🔄 Padrões Comuns

### Loading State
```swift
// ViewModel
@MainActor
func load() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        data = try await service.fetch()
    } catch {
        errorMessage = error.localizedDescription
    }
}

// View
var body: some View {
    ZStack {
        contentView
        
        if viewModel.isLoading {
            ProgressView()
        }
    }
}
```

### Error Handling
```swift
// ViewModel
private(set) var errorMessage: String?

func clearError() {
    errorMessage = nil
}

// View
if let error = viewModel.errorMessage {
    VStack {
        Text(error)
        Button("Tentar Novamente") {
            viewModel.clearError()
            Task { await viewModel.load() }
        }
    }
}
```

### Pull to Refresh
```swift
// View
List(viewModel.items) { item in
    Text(item.name)
}
.refreshable {
    await viewModel.refresh()
}

// ViewModel
func refresh() async {
    await loadData()
}
```

### Empty State
```swift
// View
if viewModel.items.isEmpty && !viewModel.isLoading {
    ContentUnavailableView(
        "Nenhum item encontrado",
        systemImage: "film",
        description: Text("Tente novamente mais tarde")
    )
}
```

---

## 🐛 Troubleshooting

### Problema: View não atualiza quando ViewModel muda

**Causa:** ViewModel não é `@Observable`

**Solução:**
```swift
// ✅ Correto
@Observable
final class MyViewModel { }

// ❌ Errado
final class MyViewModel { }
```

---

### Problema: "Cannot find 'viewModel' in scope"

**Causa:** Esqueceu de declarar `@State`

**Solução:**
```swift
// ✅ Correto
struct MyView: View {
    @State private var viewModel = MyViewModel()
}

// ❌ Errado
struct MyView: View {
    let viewModel = MyViewModel()  // Não funciona!
}
```

---

### Problema: Crash ao inicializar ViewModel com parâmetro

**Causa:** Inicialização incorreta de `@State` com dependências

**Solução:**
```swift
// ✅ Correto
struct DetailView: View {
    @State private var viewModel: DetailViewModel
    
    init(item: Item) {
        self._viewModel = State(initialValue: DetailViewModel(item: item))
    }
}

// ❌ Errado
struct DetailView: View {
    @State private var viewModel: DetailViewModel
    
    init(item: Item) {
        viewModel = DetailViewModel(item: item)  // Crash!
    }
}
```

---

### Problema: Testes falhando com erro de rede

**Causa:** Usando service real em vez de mock

**Solução:**
```swift
// ✅ Correto
@Test func test() async {
    let mock = MockFilmService()
    let vm = FilmCatalogViewModel(filmService: mock)
}

// ❌ Errado
@Test func test() async {
    let vm = FilmCatalogViewModel()  // Usa service real!
}
```

---

### Problema: "Publishing changes from background threads"

**Causa:** Atualizando propriedades @Observable fora da MainActor

**Solução:**
```swift
// ✅ Correto
@MainActor
func load() async {
    data = try await service.fetch()
}

// ou

func load() async {
    let result = try await service.fetch()
    await MainActor.run {
        data = result
    }
}

// ❌ Errado
func load() async {
    data = try await service.fetch()  // Pode estar em background thread!
}
```

---

## 📊 Checklist de Implementação

### Criar novo Service
- [ ] Criar protocol `MyServiceProtocol`
- [ ] Criar class `MyService: MyServiceProtocol`
- [ ] Adicionar `static let shared`
- [ ] Fazer init privado
- [ ] Implementar métodos async throws
- [ ] Criar `MockMyService` para testes
- [ ] Adicionar tratamento de erros
- [ ] Documentar com comentários

### Criar novo ViewModel
- [ ] Adicionar `@Observable`
- [ ] Criar propriedades `private(set)`
- [ ] Adicionar `isLoading` e `errorMessage`
- [ ] Criar init com injeção de dependência
- [ ] Implementar métodos `@MainActor func`
- [ ] Adicionar método `clearError()`
- [ ] Adicionar computed properties se necessário
- [ ] Documentar com MARK comments

### Criar nova View
- [ ] Declarar `@State private var viewModel`
- [ ] Usar apenas dados do viewModel
- [ ] Adicionar `.task { await viewModel.load() }`
- [ ] Adicionar UI de loading
- [ ] Adicionar UI de erro com retry
- [ ] Adicionar empty state
- [ ] Testar fluxo completo

### Criar Testes
- [ ] Criar arquivo `*Tests.swift`
- [ ] Adicionar `@Suite`
- [ ] Testar carregamento com sucesso
- [ ] Testar carregamento com erro
- [ ] Testar refresh
- [ ] Testar clearError
- [ ] Testar computed properties
- [ ] Rodar todos os testes (Cmd+U)

---

## 🎓 Recursos Úteis

### Comandos Xcode
```
Cmd + B           - Build
Cmd + U           - Run Tests
Cmd + Shift + O   - Open Quickly (buscar arquivo)
Cmd + Shift + F   - Find in Project
Cmd + Option + [  - Move Line Up
Cmd + Option + ]  - Move Line Down
```

### Atalhos SwiftUI
```
.task { }           - Executar quando View aparecer
.refreshable { }    - Pull to refresh
.overlay { }        - Sobrepor conteúdo
.sheet { }          - Modal sheet
.alert { }          - Alert dialog
```

### Debug
```swift
// Print no ViewModel
func load() async {
    print("🔄 Loading data...")
    data = try await service.fetch()
    print("✅ Loaded \(data.count) items")
}

// Breakpoint condicional
// Clique na linha + Ctrl + Clique → Edit Breakpoint
```

---

## 🎯 Próximos Passos

1. **Integrar API Real**
   - Substituir dados mock por API do Studio Ghibli
   - Implementar tratamento de rede

2. **Adicionar Cache**
   - Implementar UserDefaults ou CoreData
   - Cache de imagens

3. **Implementar Busca**
   - Criar SearchViewModel
   - Adicionar SearchView

4. **Sistema de Favoritos**
   - Persistência local
   - Sincronização iCloud

5. **Melhorar UI/UX**
   - Animações
   - Transições
   - Dark mode

---

## ✅ Conclusão

Você agora tem:
- ✅ Arquitetura MVVM completa
- ✅ Camada de serviço robusta
- ✅ ViewModels testáveis
- ✅ Views reativas
- ✅ Suite de testes completa
- ✅ Documentação detalhada

**O projeto está pronto para crescer! 🚀**

---

## 📞 Ajuda Rápida

**Precisa adicionar nova tela?**
→ Siga o padrão: Service → ViewModel → View → Tests

**Precisa modificar dados?**
→ Mude o Service, ViewModel se ajusta automaticamente

**Precisa mudar UI?**
→ Mude apenas a View, resto continua funcionando

**Precisa testar?**
→ Use MockService, teste o ViewModel isoladamente

---

**Mantenha a arquitetura, mantenha a qualidade! 💪**
