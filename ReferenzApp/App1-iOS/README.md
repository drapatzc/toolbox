# App1-iOS – TODO-App (MVVM + Service + Repository)

iOS/iPadOS-Referenz-App zur Verwaltung von TODO-Einträgen. Demonstriert eine klassische, klar geschichtete Architektur mit testbaren Einzelkomponenten.

---

## Architektur: MVVM + Service + Repository

```
┌─────────────────────────────────────────────────────────┐
│                        App Layer                        │
│            App1_iOSApp.swift + DependencyContainer       │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                     View Layer                          │
│         TodoListView.swift + AddTodoView.swift           │
│              (SwiftUI, @Observable binding)             │
└───────────────────────┬─────────────────────────────────┘
                        │ beobachtet / ruft auf
┌───────────────────────▼─────────────────────────────────┐
│                  ViewModel Layer                        │
│    TodoListViewModel.swift + AddTodoViewModel.swift      │
│               (@Observable, kein SwiftUI-Import)        │
└───────────────────────┬─────────────────────────────────┘
                        │ verwendet (via Protokoll)
┌───────────────────────▼─────────────────────────────────┐
│                   Service Layer                         │
│         TodoServiceProtocol + TodoService.swift          │
│            (Validierung, Geschäftsregeln)               │
└───────────────────────┬─────────────────────────────────┘
                        │ verwendet (via Protokoll)
┌───────────────────────▼─────────────────────────────────┐
│                 Repository Layer                        │
│     TodoRepositoryProtocol + InMemoryTodoRepository      │
│              (Datenhaltung, CRUD)                       │
└─────────────────────────────────────────────────────────┘
```

---

## Ordnerstruktur

```
App1-iOS/
├── App1-iOS.xcodeproj/
│   └── xcshareddata/xcschemes/
│       └── App1-iOS.xcscheme        ← Scheme: App + Tests + UI-Tests
│
├── App1-iOS/                        ← Hauptquellcode (App-Target)
│   ├── App1_iOSApp.swift            ← Einstiegspunkt (@main)
│   ├── DependencyContainer.swift    ← Dependency Injection
│   ├── Core/
│   │   ├── Models/
│   │   │   └── Todo.swift           ← Datenmodell (struct)
│   │   ├── Services/
│   │   │   ├── TodoServiceProtocol.swift
│   │   │   └── TodoService.swift    ← Validierung + Geschäftslogik
│   │   └── Repositories/
│   │       ├── TodoRepositoryProtocol.swift
│   │       └── InMemoryTodoRepository.swift
│   ├── Features/
│   │   ├── TodoList/
│   │   │   ├── TodoListView.swift
│   │   │   └── TodoListViewModel.swift
│   │   └── AddTodo/
│   │       ├── AddTodoView.swift
│   │       └── AddTodoViewModel.swift
│   └── Assets.xcassets/
│
├── App1-iOSTests/                   ← Unit-Test-Target
│   ├── Mocks/
│   │   ├── MockTodoRepository.swift
│   │   └── MockTodoService.swift
│   ├── TodoRepositoryTests.swift
│   ├── TodoServiceTests.swift
│   ├── TodoListViewModelTests.swift
│   └── AddTodoViewModelTests.swift
│
└── App1-iOSUITests/                 ← UI-Test-Target
    └── App1_iOSUITests.swift
```

---

## Wichtigste Klassen und Protokolle

| Datei | Zweck |
|---|---|
| `Todo.swift` | Datenmodell: Identifiable, Equatable, Codable |
| `TodoRepositoryProtocol` | CRUD-Schnittstelle für Datenzugriff |
| `InMemoryTodoRepository` | In-Memory-Implementierung (kein Core Data nötig) |
| `TodoServiceProtocol` | Geschäftslogik-Schnittstelle inkl. `TodoError` |
| `TodoService` | Validierung + Delegation an Repository |
| `TodoListViewModel` | @Observable: verwaltet Listeninhalt und Aktionen |
| `AddTodoViewModel` | @Observable: Eingabevalidierung + Speichern |
| `DependencyContainer` | Singleton: verdrahtet alle Abhängigkeiten |

---

## Targets und Schemes

### Targets
| Target | Typ | Beschreibung |
|---|---|---|
| `App1-iOS` | Application | Haupt-App für iPhone/iPad |
| `App1-iOSTests` | Unit Test Bundle | Swift Testing Unit-Tests, hosted in App |
| `App1-iOSUITests` | UI Test Bundle | XCTest UI-Tests |

### Scheme
**`App1-iOS.xcscheme`**: Einzelnes Scheme, das alle drei Targets verwaltet.
- `⌘R` → Startet die App im Simulator
- `⌘U` → Führt Unit-Tests und UI-Tests aus
- `Product → Test` → Alle Tests

---

## Projekt starten

1. `App1-iOS.xcodeproj` in Xcode öffnen
2. Simulator auswählen (iPhone 15, iOS 17+)
3. `⌘R` drücken

---

## Tests starten

### Alle Tests
```
Xcode: ⌘U
```

### Nur Unit-Tests
Im Test-Navigator (`⌘6`) → `App1-iOSTests` → Pfeil-Button zum Ausführen

### Nur UI-Tests
Im Test-Navigator → `App1-iOSUITests` → Pfeil-Button

### Kommandozeile (alle Tests)
```bash
xcodebuild test \
  -project App1-iOS.xcodeproj \
  -scheme "App1-iOS" \
  -destination "platform=iOS Simulator,name=iPhone 15"
```

---

## Warum ist die Architektur testbar?

1. **Constructor Injection**: Jede Klasse erhält ihre Abhängigkeiten im Initializer – kein Singleton-Lookup in der Logik.
2. **Protokolle statt Klassen**: `TodoServiceProtocol`, `TodoRepositoryProtocol` – echte Implementierungen lassen sich im Test durch Mocks ersetzen.
3. **Klare Schichttrennung**: ViewModels importieren kein SwiftUI – sie können ohne UI getestet werden.
4. **Test-Doubles**: `MockTodoRepository` und `MockTodoService` in `App1-iOSTests/Mocks/` erlauben isolierte Tests.

---

## Technische Entscheidungen

| Entscheidung | Grund |
|---|---|
| `@Observable` statt `ObservableObject` | Modernes Swift 5.9 Observation-Framework, weniger Boilerplate |
| InMemory statt CoreData | Einfachheit; die Repository-Abstraktion erlaubt späteren Austausch |
| Swift Testing für Unit-Tests | Modernste Apple-Testlösung (Xcode 16+), expressiv und wartbar |
| XCTest für UI-Tests | Industriestandard für UI-Automation, keine Alternative |
| `DependencyContainer` als Singleton | Einfache Verdrahtung für die Referenz-App; für Produktion: eigenes DI-Framework |

---

## Mindestvoraussetzungen

- Xcode 16.0+
- iOS/iPadOS 17.0+ (Simulator oder Gerät)
- Swift 5.10+
