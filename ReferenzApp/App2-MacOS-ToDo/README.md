# App2-MacOS – Aufgabenverwaltung (Redux / Unidirektionaler Datenfluss)

macOS-Referenz-App zur Verwaltung von Arbeitsaufträgen. Demonstriert den Redux-Architekturansatz mit unidirektionalem Datenfluss, zentralem State-Management und reinen Reducer-Funktionen.

---

## Architektur: Redux (Unidirektionaler Datenfluss)

```
┌────────────────────────────────────────────────────┐
│                     Views                          │
│  ContentView, TaskListView, TaskDetailView,        │
│  AddTaskView                                       │
└──────────┬────────────────────────▲────────────────┘
           │ store.dispatch(action) │ store.state
           ▼                        │
┌──────────────────────────────────────────────────┐
│                   AppStore                       │
│          (@Observable, hält AppState)            │
└──────────┬───────────────────────────────────────┘
           │ appReducer(state, action) → newState
           ▼
┌──────────────────────────────────────────────────┐
│                  appReducer()                    │
│    Reine Funktion: (AppState, AppAction) →       │
│    AppState (kein Seiteneffekt, deterministisch) │
└──────────────────────────────────────────────────┘
```

**Datenpfad (immer unidirektional):**
```
Benutzeraktion → dispatch(AppAction) → appReducer → neuer AppState → View aktualisiert sich
```

---

## Ordnerstruktur

```
App2-MacOS/
├── App2-MacOS.xcodeproj/
│   └── xcshareddata/xcschemes/
│       └── App2-MacOS.xcscheme      ← Scheme: App + Tests + UI-Tests
│
├── App2-MacOS/                      ← Hauptquellcode (App-Target)
│   ├── App2_MacOSApp.swift          ← Einstiegspunkt (@main), erstellt AppStore
│   ├── Core/
│   │   ├── Models/
│   │   │   └── WorkTask.swift       ← Datenmodell mit Priorität und Status
│   │   ├── Store/
│   │   │   ├── AppState.swift       ← Vollständiger Anwendungszustand (struct)
│   │   │   ├── AppAction.swift      ← Alle möglichen Aktionen (enum)
│   │   │   ├── AppReducer.swift     ← Reine Funktion (AppState, AppAction) → AppState
│   │   │   └── AppStore.swift       ← @Observable, dispatch(), Persistenz-Bridge
│   │   └── Persistence/
│   │       ├── PersistenceProtocol.swift
│   │       └── InMemoryPersistence.swift
│   └── Features/
│       ├── ContentView.swift        ← NavigationSplitView-Wurzel
│       ├── TaskList/
│       │   └── TaskListView.swift   ← Seitenleiste mit Filter
│       ├── TaskDetail/
│       │   └── TaskDetailView.swift ← Detailansicht mit Statuswechsel
│       └── AddTask/
│           └── AddTaskView.swift    ← Sheet-Formular für neue Aufgaben
│
├── App2-MacOSTests/                 ← Unit-Test-Target
│   ├── Mocks/
│   │   └── MockPersistence.swift
│   ├── AppReducerTests.swift        ← Tests für reine Reducer-Funktion
│   ├── AppStoreTests.swift          ← Tests für Store-Verhalten
│   └── AppStateTests.swift          ← Tests für berechnete State-Eigenschaften
│
└── App2-MacOSUITests/               ← UI-Test-Target
    └── App2_MacOSUITests.swift
```

---

## Wichtigste Klassen, Protokolle und Enums

| Datei | Zweck |
|---|---|
| `WorkTask.swift` | Datenmodell mit `TaskPriority` und `TaskStatus` Enums |
| `AppState.swift` | Struct: gesamter App-Zustand inkl. berechneter Eigenschaften |
| `AppAction.swift` | Enum: alle Aktionen, die den Zustand ändern können |
| `AppReducer.swift` | Reine Funktion: verarbeitet Aktionen ohne Seiteneffekte |
| `AppStore.swift` | @Observable: hält State, ruft Reducer auf, delegiert Persistenz |
| `PersistenceProtocol` | Abstraktion der Datenschicht |
| `InMemoryPersistence` | Testbare In-Memory-Implementierung |

---

## Targets und Schemes

### Targets
| Target | Typ | Beschreibung |
|---|---|---|
| `App2-MacOS` | Application | Haupt-App für macOS |
| `App2-MacOSTests` | Unit Test Bundle | Swift Testing Unit-Tests |
| `App2-MacOSUITests` | UI Test Bundle | XCTest UI-Tests |

### Scheme
**`App2-MacOS.xcscheme`**: Verwaltet alle drei Targets.
- `⌘R` → Startet die macOS-App
- `⌘U` → Alle Tests (Unit + UI)

---

## Projekt starten

1. `App2-MacOS.xcodeproj` in Xcode öffnen
2. `My Mac` als Ziel auswählen (links neben dem Play-Button)
3. `⌘R` drücken

---

## Tests starten

### Alle Tests
```
Xcode: ⌘U
```

### Kommandozeile
```bash
xcodebuild test \
  -project App2-MacOS.xcodeproj \
  -scheme "App2-MacOS" \
  -destination "platform=macOS"
```

---

## Warum ist diese Architektur testbar?

### 1. Reducer als reine Funktion
Der Reducer ist die einfachste testbare Einheit überhaupt:
```swift
let state = AppState()
let action = AppAction.addTask(title: "Test", description: "", priority: .high)
let newState = appReducer(state: state, action: action)
// → Kein Mock, keine Injektion nötig
```

### 2. AppState als Werttyp
Da `AppState` ein `struct` ist, sind Zustandsänderungen vollständig vorhersehbar. Es gibt keine versteckten Referenzeffekte.

### 3. AppStore mit injizierbarer Persistenz
```swift
let store = AppStore(persistence: MockPersistence())
// → Persistenz testbar ohne echtes Schreiben
```

### 4. Determinismus
Gleicher State + gleiche Action = immer gleicher neuer State. Das erlaubt exakte Assertions ohne Toleranzwerte.

---

## Funktionale Anforderungen der App

- Aufgaben anlegen (Titel, Beschreibung, Priorität)
- Aufgaben nach Status filtern (Offen / In Bearbeitung / Erledigt)
- Status einer Aufgabe wechseln
- Aufgabe löschen
- Aufgabe auswählen und Details anzeigen
- NavigationSplitView: Seitenleiste + Detailbereich (typisch macOS)

---

## Technische Entscheidungen

| Entscheidung | Grund |
|---|---|
| Redux statt MVVM | Demonstration einer klar anderen Architektur als App1 |
| Zentraler AppState (struct) | Single Source of Truth, verhindert inkonsistente Zustände |
| Reine Reducer-Funktion | Einfachste testbare Einheit, keine Mocks nötig |
| NavigationSplitView | Typische macOS-UI-Konvention (Seitenleiste + Inhalt) |
| `WorkTask` statt `Task` | Namenskonflikt mit Swift Concurrency vermieden |
| InMemoryPersistence | Einfachheit; Protokoll erlaubt spätere UserDefaults/CoreData-Integration |

---

## Mindestvoraussetzungen

- Xcode 16.0+
- macOS 14.0 (Sonoma)+
- Swift 5.10+
