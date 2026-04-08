# App3-iOS – Wetter-App (Referenz-Implementierung)

iOS-Wetter-App mit gemockten Daten als Referenz-Implementierung für MVVM + Service + Repository Architektur.

## Überblick

Die App zeigt für zehn Städte aktuelles Wetter und eine 7-Tage-Vorhersage. Alle Daten sind statisch gemockt – es werden keine Netzwerkanfragen gestellt.

## Plattform

- **iOS / iPadOS**: 17.0+
- **Xcode**: 16.0+
- **Swift**: 5.10+
- **Frameworks**: SwiftUI, Foundation, Testing

## Architektur

**MVVM + Service + Repository**

```
View → ViewModel → Service → Repository → Beispieldaten
```

| Schicht | Zweck |
|---|---|
| **View** | SwiftUI-Ansichten, kein Business-Logik |
| **ViewModel** | `@Observable`-Klassen, steuert UI-Zustand |
| **Service** | Validierung, asynchrone Bereitstellung |
| **Repository** | Datenzugriff, `WeatherSampleRepository` mit Festwerten |

## Projektstruktur

```
App3-iOS/
├── App3-iOS/                    # App-Target
│   ├── App3_iOSApp.swift
│   ├── DependencyContainer.swift
│   ├── Core/
│   │   ├── Models/              # City, WeatherCondition, CurrentWeather,
│   │   │                        # DailyForecast, WeeklyForecast
│   │   ├── Repositories/        # WeatherRepositoryProtocol, WeatherSampleRepository
│   │   └── Services/            # WeatherServiceProtocol (+ WetterFehler), WeatherService
│   └── Features/
│       ├── CitySearch/          # CitySearchView + CitySearchViewModel
│       ├── CurrentWeather/      # CurrentWeatherView + CurrentWeatherViewModel
│       └── Forecast/            # ForecastView + ForecastViewModel
├── App3-iOSTests/               # Unit-Test-Target (Swift Testing)
│   ├── Mocks/                   # MockWeatherRepository, MockWeatherService
│   ├── WeatherRepositoryTests.swift
│   ├── WeatherServiceTests.swift
│   ├── CurrentWeatherViewModelTests.swift
│   ├── ForecastViewModelTests.swift
│   └── CitySearchViewModelTests.swift
└── TestPlans/                   # Testpläne
    ├── AllTests.xctestplan       # Alle Tests (Standard)
    ├── RepositoryTests.xctestplan
    ├── ServiceTests.xctestplan
    └── ViewModelTests.xctestplan
```

## Testpläne

| Plan | Inhalt | Verwendung |
|---|---|---|
| **AllTests** | Alle Unit-Tests | Standard `⌘U` |
| **RepositoryTests** | Nur `WeatherRepositoryTests` | Repository isoliert testen |
| **ServiceTests** | Nur `WeatherServiceTests` | Service isoliert testen |
| **ViewModelTests** | Alle ViewModel-Tests | ViewModels isoliert testen |

Testplan-Wechsel in Xcode: **Product → Test Plan → [Plan auswählen]**

## Tests ausführen

```
⌘U          → Aktiven Testplan ausführen (Standard: AllTests)
```

Insgesamt ca. **75 Unit-Tests** mit positiven und negativen Szenarien,
implementiert mit dem modernen Swift-Testing-Framework (`import Testing`).

## Navigation

```
CitySearchView          → Stadt aus Liste wählen / suchen
  └── CurrentWeatherView  → Aktuelles Wetter der gewählten Stadt
        └── ForecastView    → 7-Tage-Vorhersage
```

## Designentscheidungen

- **Kein `@MainActor`**: ViewModels sind `@Observable` ohne explizite Actor-Annotierung (reicht für Referenz-App mit gemockten Daten).
- **Deterministische Testdaten**: `WeatherSampleRepository` verwendet die Stadtposition im Array als Index für die Wettervariante – kein `hashValue` (nicht stabil zwischen Builds).
- **`WetterFehler` in `WeatherServiceProtocol.swift`**: Ähnlich wie `TodoError` in App1 – Fehler und Protokoll in einer Datei.
