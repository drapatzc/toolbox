# Xcode Developer Toolbox

Ein interaktives Terminal-Werkzeug fuer iOS- und macOS-Entwickler.  
Vereint Build, Test, Simulator, Code-Qualitaet, Git-Analyse, Distribution und viele weitere Entwickler-Hilfsfunktionen in einem uebersichtlichen Menue — gesteuert ueber ein einziges Swift-Projekt.

---

## Warum dieses Tool?

Im Alltag eines Apple-Entwicklers wechselt man staendig zwischen Xcode, Terminal und diversen CLI-Tools: `xcodebuild`, `xcrun simctl`, `agvtool`, `otool`, `codesign`, `swiftlint`, `git log` …  
Jedes Tool hat eigene Flags, eigene Syntax und eigene Fallstricke.

**Xcode Developer Toolbox** buendelt all das in einem einzigen Einstiegspunkt:

- **Kein Flag-Nachschlagen** — alle gaengigen Workflows sind als Menuepunkte verfuegbar.
- **Kein Kontextwechsel** — Build, Test, Clean, Analyse, Distribution und Git-Abfragen laufen alle im selben Terminal.
- **Kein versehentliches Aendern** — saemtliche Analyse- und Git-Funktionen arbeiten **rein lesend** und veraendern weder Code noch Repository.
- **Sofort einsatzbereit** — keine externen Dependencies, laeuft ueberall wo Xcode installiert ist.

---

## Installation

```bash
git clone https://github.com/drapatzc/toolbox.git
cd toolbox
```

---

## Starten

Das Tool im **Stammverzeichnis des Xcode-Projekts** ausfuehren, das analysiert werden soll:

```bash
cd MeinXcodeProjekt
../toolbox/toolbox
```

Das Tool erkennt automatisch `.xcworkspace`- oder `.xcodeproj`-Dateien im aktuellen Verzeichnis.

### Bedienung

| Eingabe | Aktion |
|---------|--------|
| Zahl + Enter | Menuepunkt aufrufen |
| `X` oder `Q` + Enter | Zurueck / Beenden |
| `S` | Schema waehlen |
| `D` | Device / Simulator waehlen |
| `K` | Konfiguration (Debug / Release) |
| `N` | Benutzername setzen (fuer Git) |
| `B` | Bundle-ID setzen |
| `M` | Modus umschalten (Einfach / Erweitert) |
| `H` | Kontextsensitive Hilfe |

Einstellungen werden in `~/.xcode_toolbox_prefs.json` persistent gespeichert.

---

## Funktionen

Das Tool bietet zwei Modi: ein **einfaches Menue** mit den wichtigsten Tagesaufgaben und ein **erweitertes Menue** mit 20 Untermenues und ueber 100 Einzelfunktionen.

### Entwicklung

| Menue | Beschreibung |
|-------|-------------|
| **Clean & Cache** | Derived Data, Module Cache, Simulator-Daten und SPM-Cache loeschen |
| **Build & Simulator** | Bauen, starten, Simulator steuern (Screenshot, Dark/Light Mode, Reset) |
| **Test** | Unit-Tests, UI-Tests, Code Coverage und Test-Reports |
| **Physische Geraete** | App auf echtem Geraet installieren und steuern via `devicectl` |
| **Dependencies** | SPM, CocoaPods und Carthage verwalten |
| **Versionsverwaltung** | Build- und Marketing-Version aendern via `agvtool` |

### Analyse & Qualitaet

| Menue | Beschreibung |
|-------|-------------|
| **Code-Qualitaet** | 63 statische Pruefungen nach Mustern und Risiken (z. B. force-unwraps, retain cycles, TODOs) |
| **Projekt-Analyse** | 38 lesende Analysen zu Struktur, Imports, Protokollen und Dateigrenzen |
| **Metriken** | Quality-Score, Datei-Metriken, Risikoliste und exportierbare Reports |
| **Git** | 23 lesende Abfragen zu Verlauf, Autoren, Branches und Commit-Suche |
| **Crash & Symbole** | `symbolicatecrash`, `atos`, xcresult-Auswertung und dSYM-Handling |
| **Binaeranalyse** | `otool`, `lipo`, `nm`, `strings` fuer das fertige App-Binary |

### Distribution

| Menue | Beschreibung |
|-------|-------------|
| **Distribution & App Store** | IPA erstellen, Upload, Notarisierung, Release-Workflows |
| **Lokalisierung** | Strings-Dateien pruefen, fehlende Keys und Platzhalter-Validierung |
| **Profiling** | Instruments starten, Build-Zeiten analysieren, Cache-Groessen auswerten |
| **XCFramework** | Device- und Simulator-Builds zu Universal-Frameworks kombinieren |
| **Dokumentation** | DocC generieren, vorschauen und bauen |
| **Zertifikate & Signing** | Zertifikate, Provisioning Profiles und `notarytool`-Integration |

### System & Tools

| Menue | Beschreibung |
|-------|-------------|
| **Xcode verwalten** | Xcode oeffnen, schliessen und zwischen Versionen wechseln |
| **Info & Diagnose** | Disk-Usage, installierte Tool-Versionen und Systeminfo |

---

## Voraussetzungen

| Voraussetzung | Hinweis |
|---------------|---------|
| **macOS** | Getestet ab macOS 13+ |
| **Xcode** | Inkl. Xcode Command Line Tools (`xcode-select --install`) |
| **Swift 5.9+** | Wird mit Xcode mitgeliefert |

### Optionale Tools

Einige Menuepunkte nutzen externe Tools, die ueber Homebrew installiert werden koennen. Ohne diese Tools sind die jeweiligen Funktionen nicht verfuegbar, der Rest des Tools laeuft uneingeschraenkt.

```bash
brew install swiftlint     # Code-Qualitaet: Linting
brew install swiftformat   # Code-Qualitaet: Formatierung
brew install periphery     # Projekt-Analyse: Unused Code Detection
```

---

## Projektstruktur

```
toolbox/
├── toolbox                   # Ausfuehrbares Binary
├── README.md
├── Localizable.xcstrings     # Lokalisierung (DE+EN, ~1500 Keys)
└── Documentation/
    ├── index.html
    ├── DESCRIPTION.md
    ├── DESCRIPTION.txt
    └── XcodeDeveloperToolbox_Presentation.pptx
```

---

## Technische Umsetzung

- **Sprache:** Swift
- **Build-System:** Swift Package Manager (SPM)
- **Plattform:** macOS (Executable Target)
- **UI:** ANSI-Escape-Sequenzen fuer Farben, Fortschrittsbalken und Spinner im Terminal
- **Persistenz:** Benutzereinstellungen als JSON in `~/.xcode_toolbox_prefs.json`
- **Architektur:** Modularer Aufbau mit getrennten Core-, Menü-, Action- und Project-Schichten
- **Sicherheit:** Analyse-Funktionen arbeiten ausschliesslich lesend — keine automatischen Code-Aenderungen, keine Git-Writes
- **Signal-Handling:** `Ctrl+C` bricht laufende Vorgaenge sicher ab, ohne das Tool zu beenden
- **Keine externen Dependencies** — nur Foundation und Xcode Command Line Tools

---

## Autor

Christian Drapatz — 2026

---

## Lizenz

Dieses Projekt ist nicht unter einer Open-Source-Lizenz veroeffentlicht.  
Alle Rechte vorbehalten.
