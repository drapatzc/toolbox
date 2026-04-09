# ReferenzApp – Überblick

Zwei vollständige Xcode-Referenzprojekte als technische Vorlage für iOS/iPadOS- und macOS-Entwicklung mit SwiftUI, modernen Apple-Frameworks und testbarer Architektur.

---

## Projekte auf einen Blick

| | App1-iOS | App2-MacOS |
|---|---|---|
| **Plattform** | iOS 17+ / iPadOS 17+ | macOS 14+ |
| **Architektur** | MVVM + Service + Repository | Redux (Unidirektionaler Datenfluss) |
| **App-Typ** | TODO-Verwaltung | Aufgaben- und Arbeitsmanagement |
| **Datenhaltung** | InMemory-Repository | InMemory-Persistenz |
| **Unit-Test-Framework** | Swift Testing | Swift Testing |
| **UI-Test-Framework** | XCTest (XCUI) | XCTest (XCUI) |

---

## Architektur App1-iOS: MVVM + Service + Repository

```
View ──► ViewModel ──► Service ──► Repository
```

Jede Schicht ist über ein Protokoll abstrahiert:
- **View** (`SwiftUI`): Zeigt Daten an, leitet Aktionen ans ViewModel weiter
- **ViewModel** (`@Observable`): Hält UI-Zustand, orchestriert Service-Aufrufe
- **Service** (`TodoServiceProtocol`): Geschäftslogik, Validierung
- **Repository** (`TodoRepositoryProtocol`): Datenzugriff, CRUD-Operationen
- **DependencyContainer**: Singleton, der Abhängigkeiten verdrahtet

**Warum testbar?**
- ViewModels und Services erhalten ihre Abhängigkeiten per Injektion (Constructor Injection)
- Protokolle erlauben das Ersetzen echter Implementierungen durch Mocks
- Mocks liegen im Ordner `App1-iOSTests/Mocks/`

---

## Architektur App2-MacOS: Redux (Unidirektionaler Datenfluss)

```
View ──► dispatch(Action) ──► Reducer(State, Action) = NewState ──► View
```

Kernelemente:
- **AppState** (`struct`): Unveränderlicher Gesamtzustand der App (Single Source of Truth)
- **AppAction** (`enum`): Alle möglichen Zustandsänderungen als typisierte Aktionen
- **appReducer** (`func`): Reine Funktion ohne Seiteneffekte; `(State, Action) -> State`
- **AppStore** (`@Observable class`): Hält den State, ruft den Reducer auf, delegiert Persistenz
- **PersistenceProtocol**: Abstraktion der Datenhaltung

**Warum testbar?**
- Der Reducer ist eine reine Funktion: kein Mocking nötig
- AppState ist ein Werttyp (struct): Zustandsänderungen sind vorhersehbar
- MockPersistence ersetzt die echte Persistenz im Test

---

## Unterschiede der Architekturen

| Aspekt | App1-iOS (MVVM) | App2-MacOS (Redux) |
|---|---|---|
| **Zustandsverwaltung** | Verteilt auf mehrere ViewModels | Zentralisiert in einem AppState |
| **Mutation** | Methoden im ViewModel ändern Zustand direkt | Nur über dispatch → Reducer |
| **Testansatz** | Mocks für Service/Repository | Direkte Reducer-Tests ohne Mocks |
| **Datenstrom** | Bidirektional (Binding) | Unidirektional (Action → State → View) |
| **Skalierung** | Gut für mittlere Apps mit klaren Features | Gut für komplexe Apps mit viel geteiltem Zustand |

---

## Projektstart in Xcode

### App1-iOS öffnen
```
Xcode → File → Open → App1-iOS/App1-iOS.xcodeproj
```
Dann Simulator auswählen (z. B. iPhone 15) und `⌘R` drücken.

### App2-MacOS öffnen
```
Xcode → File → Open → App2-MacOS/App2-MacOS.xcodeproj
```
Dann `My Mac` als Ziel auswählen und `⌘R` drücken.

---

## Tests ausführen

### Unit-Tests + UI-Tests (alle zusammen)
In Xcode: `⌘U`

### Nur Unit-Tests (per Tastatur)
In Xcode: `Product → Test` oder `⌘U`, dann im Test-Navigator nur Unit-Tests auswählen.

### Tests aus der Kommandozeile

**App1-iOS Unit-Tests:**
```bash
cd App1-iOS
xcodebuild test \
  -project App1-iOS.xcodeproj \
  -scheme "App1-iOS" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -only-testing:App1-iOSTests
```

**App2-MacOS Unit-Tests:**
```bash
cd App2-MacOS
xcodebuild test \
  -project App2-MacOS.xcodeproj \
  -scheme "App2-MacOS" \
  -destination "platform=macOS" \
  -only-testing:App2-MacOSTests
```

---

## TestTargets und TestSchemes erklärt

### Was ist ein TestTarget?
Ein TestTarget ist ein separates Build-Ziel, das nur für Tests kompiliert wird. Es hat Zugriff auf den App-Code über `@testable import`. Jedes Projekt enthält:
- **UnitTest-Target**: Enthält Unit-Tests mit Swift Testing (`import Testing`)
- **UITest-Target**: Enthält UI-Tests mit XCTest (`import XCTest`)

### Was ist ein TestScheme?
Ein Scheme definiert, welche Targets wie gebaut und getestet werden. Beide Projekte haben ein zentrales Scheme (z. B. `App1-iOS.xcscheme`), das:
1. Die App baut
2. Unit-Tests ausführt
3. UI-Tests ausführt

---

## SwiftLint

Die gemeinsame `.swiftlint.yml` liegt im Root-Verzeichnis `ReferenzApp/`.

SwiftLint kann als Build-Phase in jedem Projekt eingebunden werden:
```bash
# Build Phase Script:
if command -v swiftlint &> /dev/null; then
    swiftlint
fi
```

Oder direkt ausführen:
```bash
cd ReferenzApp
swiftlint
```

---

## Voraussetzungen

- Xcode 16.0 oder neuer
- macOS 14.0 oder neuer (für die Entwicklung)
- Swift 5.10+
- SwiftLint (optional, via Homebrew: `brew install swiftlint`)
