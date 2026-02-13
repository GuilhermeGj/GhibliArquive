//
//  ProjectStructure.md
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

# 📁 Estrutura de Organização do Projeto

## 🎯 Estrutura Atual vs Estrutura Recomendada

### ❌ Antes (Todos os arquivos na raiz)
```
Ghibli Archive/
├── Ghibli_ArchiveApp.swift
├── ContentView.swift
├── Film.swift
├── FilmCatalogView.swift
├── FilmDetailView.swift
├── AppCoordinator.swift
└── Assets.xcassets
```

**Problemas:**
- Difícil de navegar
- Sem organização lógica
- Escala mal com crescimento
- Difícil encontrar arquivos

---

### ✅ Depois (Organizado por funcionalidade)

```
Ghibli Archive/
│
├── 📱 App/
│   └── Ghibli_ArchiveApp.swift
│
├── 📦 Models/
│   ├── Film.swift
│   └── Director.swift (futuro)
│
├── 🔧 Services/
│   ├── FilmService.swift
│   ├── NetworkService.swift (futuro)
│   └── CacheService.swift (futuro)
│
├── 🧠 ViewModels/
│   ├── FilmCatalogViewModel.swift
│   ├── FilmDetailViewModel.swift
│   └── FilmSearchViewModel.swift (futuro)
│
├── 🎨 Views/
│   ├── Catalog/
│   │   ├── FilmCatalogView.swift
│   │   └── FilmCardView.swift
│   │
│   ├── Detail/
│   │   ├── FilmDetailView.swift
│   │   ├── InfoCard.swift
│   │   └── SectionCard.swift
│   │
│   ├── Search/
│   │   └── FilmSearchView.swift (futuro)
│   │
│   └── ContentView.swift
│
├── 🧭 Navigation/
│   └── AppCoordinator.swift
│
├── 🎨 Resources/
│   ├── Assets.xcassets
│   ├── Colors/
│   │   └── ColorConstants.swift
│   └── Fonts/
│       └── FontConstants.swift
│
├── 🛠️ Utilities/
│   ├── Extensions/
│   │   ├── String+Extensions.swift
│   │   └── View+Extensions.swift
│   │
│   └── Helpers/
│       └── DateFormatter.swift
│
├── 📚 Documentation/
│   ├── MVVM_Architecture.md
│   ├── README_MVVM.md
│   ├── ArchitectureDiagram.swift
│   └── ProjectStructure.md
│
└── 🧪 Tests/
    ├── ViewModelTests/
    │   ├── FilmCatalogViewModelTests.swift
    │   └── FilmDetailViewModelTests.swift
    │
    ├── ServiceTests/
    │   └── FilmServiceTests.swift
    │
    └── UITests/
        └── FilmCatalogUITests.swift
```

---

## 📂 Descrição das Pastas

### 📱 App
**Propósito:** Ponto de entrada do aplicativo
- `@main` App struct
- Configurações iniciais
- Environment setup

**Arquivos:**
```swift
// Ghibli_ArchiveApp.swift
@main
struct Ghibli_ArchiveApp: App {
    @State private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coordinator)
        }
    }
}
```

---

### 📦 Models
**Propósito:** Entidades de dados
- Structs e Classes de dados
- Protocolos de modelo
- Extensões de modelo

**Convenções:**
- ✅ Imutável quando possível (`let`)
- ✅ `Identifiable` para listas
- ✅ `Hashable` para sets/comparações
- ✅ `Codable` para serialização

**Exemplo:**
```swift
// Film.swift
struct Film: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    // ...
}
```

---

### 🔧 Services
**Propósito:** Camada de acesso a dados
- APIs de rede
- Cache local
- Persistência de dados
- Integrações externas

**Convenções:**
- ✅ Protocol-based
- ✅ Async/await
- ✅ Error handling robusto
- ✅ Singleton quando apropriado

**Estrutura típica:**
```swift
protocol ServiceProtocol {
    func fetch() async throws -> Data
}

final class Service: ServiceProtocol {
    static let shared = Service()
    private init() {}
    
    func fetch() async throws -> Data {
        // Implementação
    }
}

final class MockService: ServiceProtocol {
    func fetch() async throws -> Data {
        // Mock data
    }
}
```

---

### 🧠 ViewModels
**Propósito:** Lógica de apresentação e estado
- Gerenciamento de estado
- Lógica de negócio
- Formatação de dados
- Coordenação entre services

**Convenções:**
- ✅ `@Observable` (iOS 17+)
- ✅ `private(set)` para propriedades
- ✅ Métodos `@MainActor` quando necessário
- ✅ Injeção de dependências

**Estrutura típica:**
```swift
@Observable
final class FeatureViewModel {
    // MARK: - Properties
    private(set) var data: [Model] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let service: ServiceProtocol
    
    // MARK: - Initialization
    init(service: ServiceProtocol = Service.shared) {
        self.service = service
    }
    
    // MARK: - Public Methods
    @MainActor
    func loadData() async {
        // Implementação
    }
}
```

---

### 🎨 Views
**Propósito:** Interface do usuário
- Componentes visuais
- Layout e styling
- Interações do usuário

**Organização por feature:**
```
Views/
├── Catalog/          ← Feature completa
│   ├── FilmCatalogView.swift
│   └── Components/
│       └── FilmCardView.swift
│
├── Detail/           ← Feature completa
│   ├── FilmDetailView.swift
│   └── Components/
│       ├── InfoCard.swift
│       └── SectionCard.swift
│
└── Shared/           ← Componentes reutilizáveis
    ├── LoadingView.swift
    └── ErrorView.swift
```

**Convenções:**
- ✅ Views pequenas e focadas
- ✅ Extrair subviews complexas
- ✅ Usar `@State` para ViewModels
- ✅ Separar Views de componentes

---

### 🧭 Navigation
**Propósito:** Coordenação de navegação
- Coordinators/Routers
- Deep linking
- Fluxo de navegação

**Exemplo:**
```swift
@Observable
class AppCoordinator {
    var path = NavigationPath()
    
    enum Destination: Hashable {
        case catalog
        case detail(Film)
    }
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
}
```

---

### 🎨 Resources
**Propósito:** Recursos estáticos
- Assets (imagens, cores)
- Constantes de design
- Arquivos de localização

**Exemplo:**
```swift
// ColorConstants.swift
extension Color {
    static let ghibliRed = Color(red: 0.6, green: 0.15, blue: 0.25)
    static let ghibliGold = Color(red: 0.85, green: 0.65, blue: 0.25)
    static let ghibliBackground = Color(red: 0.98, green: 0.97, blue: 0.95)
}

// FontConstants.swift
extension Font {
    static let ghibliTitle = Font.system(size: 56, weight: .bold)
    static let ghibliBody = Font.system(size: 18, weight: .regular)
}
```

---

### 🛠️ Utilities
**Propósito:** Helpers e extensões
- Extensions de tipos nativos
- Helper functions
- Utilitários reutilizáveis

**Exemplos:**
```swift
// String+Extensions.swift
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

// View+Extensions.swift
extension View {
    func ghibliCard() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
    }
}
```

---

### 📚 Documentation
**Propósito:** Documentação do projeto
- Guias de arquitetura
- READMEs
- Diagramas
- Decisões técnicas

---

### 🧪 Tests
**Propósito:** Testes automatizados
- Unit tests
- Integration tests
- UI tests

**Organização espelhada:**
```
Tests/
├── ViewModelTests/
│   └── FilmCatalogViewModelTests.swift
├── ServiceTests/
│   └── FilmServiceTests.swift
└── UITests/
    └── FilmCatalogUITests.swift
```

---

## 🎯 Como Organizar no Xcode

### 1. Criar Groups (não folders)
```
Clique com botão direito → New Group
```

### 2. Mover arquivos
```
Arraste e solte os arquivos nos groups apropriados
```

### 3. Manter sincronizado com sistema de arquivos
```
Editar → Estrutura → Sincronizar com Finder
```

---

## 📊 Matriz de Decisão: Onde colocar o arquivo?

| Se o arquivo é...              | Vai para...        |
|--------------------------------|--------------------|
| Struct/Class de dados          | Models/            |
| Busca dados externos           | Services/          |
| Gerencia estado/lógica         | ViewModels/        |
| Componente visual              | Views/             |
| Coordena navegação             | Navigation/        |
| Imagem/Cor/Asset               | Resources/         |
| Extension/Helper               | Utilities/         |
| Documentação                   | Documentation/     |
| Teste                          | Tests/             |

---

## 🚀 Benefícios da Organização

### ✅ Navegação Rápida
```
Cmd + Shift + O → Digite nome do arquivo
Fácil de encontrar quando bem organizado!
```

### ✅ Onboarding de Novos Devs
```
Estrutura clara = fácil entender o projeto
Novos membros sabem onde colocar código novo
```

### ✅ Manutenção
```
Bug no catálogo? Vai direto para Views/Catalog/
Problema na API? Vai em Services/
```

### ✅ Escalabilidade
```
Novo feature? Cria nova pasta em Views/
Novo serviço? Adiciona em Services/
Cresce organizadamente!
```

### ✅ Code Review
```
PR muda apenas Services/ → Revisor foca nisso
PR toca Views/ e ViewModels/ → Revisor sabe escopo
```

---

## 📝 Convenções de Nomenclatura

### Arquivos
```
✅ PascalCase
✅ Descritivo
✅ Sufixo indica tipo

Exemplos:
- FilmCatalogView.swift      (View)
- FilmCatalogViewModel.swift (ViewModel)
- FilmService.swift          (Service)
- Film.swift                 (Model)
```

### Groups/Folders
```
✅ PascalCase ou plurais
✅ Agrupam por funcionalidade

Exemplos:
- Views/
- ViewModels/
- Services/
- Catalog/
- Detail/
```

---

## 🎓 Exemplo Prático: Adicionar Feature de Busca

### 1. Criar Model (se necessário)
```
Models/SearchQuery.swift
```

### 2. Adicionar método no Service
```swift
// Services/FilmService.swift
func searchFilms(query: String) async throws -> [Film]
```

### 3. Criar ViewModel
```
ViewModels/FilmSearchViewModel.swift
```

### 4. Criar View
```
Views/Search/FilmSearchView.swift
```

### 5. Criar Testes
```
Tests/ViewModelTests/FilmSearchViewModelTests.swift
```

### 6. Atualizar Coordinator
```swift
// Navigation/AppCoordinator.swift
enum Destination {
    case search
}
```

---

## ✅ Checklist de Migração

- [ ] Criar estrutura de pastas no Xcode
- [ ] Mover arquivos App/ para pasta App
- [ ] Mover Models para pasta Models
- [ ] Mover Services para pasta Services
- [ ] Mover ViewModels para pasta ViewModels
- [ ] Mover Views para pasta Views
- [ ] Criar subpastas por feature em Views
- [ ] Mover Coordinator para Navigation
- [ ] Criar pasta Resources
- [ ] Extrair constantes de cores/fonts
- [ ] Criar pasta Utilities
- [ ] Mover extensions
- [ ] Criar pasta Documentation
- [ ] Mover documentação
- [ ] Organizar Tests
- [ ] Sincronizar com sistema de arquivos
- [ ] Testar compilação
- [ ] Atualizar .gitignore se necessário

---

## 🎉 Resultado Final

### Antes
```
😕 Difícil de navegar
😕 Todos os arquivos misturados
😕 Escala mal
```

### Depois
```
😊 Organizado e profissional
😊 Fácil encontrar arquivos
😊 Escala perfeitamente
😊 Novo dev entende rapidamente
😊 Manutenção simplificada
```

---

**Estrutura bem organizada = Projeto profissional! 🚀**
