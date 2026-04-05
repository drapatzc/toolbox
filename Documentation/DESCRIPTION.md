# Xcode Developer Toolbox

**Alle Xcode-Workflows. Ein Tool.**

Xcode Developer Toolbox ist ein interaktives Swift-CLI-Tool für iOS- und macOS-Entwickler. Es bündelt über 100 typische Entwickler-Aufgaben in einem tastaturgesteuerten Terminal-Menü — von Build & Test über Code-Analyse bis hin zu Distribution und Debugging.

---

## Überblick

- **Plattform:** macOS 13+
- **Sprache:** Swift (kein externes Dependency)
- **Build-Tool:** Swift Package Manager
- **Lokalisierung:** Deutsch und Englisch (umschaltbar im laufenden Betrieb)
- **Installation:** `git clone https://github.com/drapatzc/toolbox.git`
- **Start:** Im Stammverzeichnis des Xcode-Projekts: `../toolbox/toolbox`

---

## Die drei Modi

### Simple Mode
16 der meistgenutzten Aktionen auf einen Blick — optimiert für den täglichen Entwickleralltag:
- Cache leeren (4 Varianten: Derived Data, Module Cache, Simulator, SPM)
- Build & Run, App starten, Quick Reset & Build
- Unit Tests ausführen
- Simulator stoppen, Screenshot, Dark/Light Mode umschalten
- Xcode öffnen, schließen, neu starten
- Arbeitsverzeichnis wechseln, Apps öffnen

### Extended Mode
22 Themenbereiche mit über 100 Aktionen für tiefgehende Analysen und erweiterte Workflows:

| Nr | Bereich | Highlights |
|----|---------|------------|
| 01 | Clean & Cache | Derived Data, Module Cache, Simulator, SPM, Xcode |
| 02 | Build & Simulator | Build & Run, Reset, Simulator-Steuerung, Screenshot |
| 03 | Testing | Unit/UI Tests, Code Coverage, JUnit-Report, Markdown-Report |
| 04 | Physische Geräte | devicectl: Install, Launch, Logs, Diagnose |
| 05 | Abhängigkeiten | SPM, CocoaPods, Carthage |
| 06 | Versionsverwaltung | Build-Nummer, Marketing-Version, agvtool |
| 07 | Code Quality | SwiftLint, SwiftFormat, Periphery, Analyzer, 59 eigene Checks |
| 08 | Projektanalyse | 38 Read-only-Abfragen (LOC, Struktur, Patterns, Assets) |
| 09 | Metriken | 5-Punkte-Qualitätsscore, Risiko-Ranking, Markdown-Report |
| 10 | Git-Analyse | 55+ Abfragen in 8 Kategorien (Status, Branches, Statistiken…) |
| 11 | Crash & Symbole | Symbolicaten, atos, dSYM, xcresult, Crash-Logs |
| 12 | Binäranalyse | otool, lipo, nm, Entitlements, Hardcoded Strings |
| 13 | Distribution | IPA Export, TestFlight/App Store Upload, Notarisierung, Checkliste |
| 14 | Lokalisierung | Fehlende Keys, ungenutzte Keys, Platzhalter-Checks |
| 15 | Profiling | Instruments, Build Timing, Warnungen zählen |
| 16 | XCFramework | Erstellen, Inhalte anzeigen, Device/Simulator separat |
| 17 | Dokumentation | DocC generieren, Preview, undokumentierte API finden |
| 18 | Code Signing | Zertifikate, Profile, Entitlements, Notarisierungshistorie |
| 19 | Xcode verwalten | Öffnen, Schließen, Neu starten, Versionen wechseln |
| 20 | Info & Diagnose | Disk-Übersicht, Tool-Versionen, Git-Status, Prozesse |
| 21 | Verzeichnis-Browser | Tastaturgesteuerter Verzeichniswechsel |
| 22 | Apps öffnen | Entwicklertools, Systemapps, eigene Apps |

### Custom Mode
20 frei belegbare Slots — beliebige Aktionen und Untermenüs aus allen 22 Bereichen individuell zusammenstellen. Reihenfolge frei konfigurierbar, persistent gespeichert, jederzeit über `M)` umschaltbar.

---

## Globale Tastenkürzel

Jederzeit verfügbar, unabhängig vom aktuellen Menü:

| Taste | Funktion |
|-------|----------|
| S | Schema wählen |
| D | Gerät wählen |
| K | Konfiguration (Debug/Release) |
| B | Bundle-ID setzen |
| N | Benutzername (Git-Commits) |
| C | Crash-Export-Pfad |
| L | Sprache umschalten (DE/EN) |
| M | Modus wechseln (Simple/Extended/Custom) |
| H | Hilfe anzeigen |
| R | Einstellungen zurücksetzen |
| X | Zurück |
| Q | Beenden |

---

## Persistente Einstellungen

Schema, Gerät, Konfiguration, Bundle-ID, Benutzername, Modus, Sprache und Arbeitsverzeichnis werden in `~/.xcode_toolbox_prefs.json` gespeichert und beim nächsten Start wiederhergestellt.

---

## Code Quality — 59 eigene Checks

Neben SwiftLint, SwiftFormat, Periphery und dem statischen Analyzer prüft das Tool mit eigenen Mustern auf:

- Force Unwraps (`!`), `try!`, `as!`, `fatalError`
- Lange Funktionen (>50 Zeilen), große Dateien (>300 Zeilen)
- Tiefe Verschachtelung (>4 Ebenen), lange Parameter-Listen (>4)
- Potenzielle Retain Cycles, Singletons
- `NSLog`, hardcodierte URLs und Credentials
- Leere Catch-Blöcke, `async` ohne `await`, `Task` ohne `await`
- Fehlende Dokumentation, Magic Numbers, kurze Variablennamen
- Und viele weitere Pattern-Checks

---

## Git-Analyse — 55+ Abfragen in 8 Kategorien

1. **Status & Änderungen** — Git-Status, Diffs, Konflikte prüfen
2. **Branches & Vergleich** — Visueller Log, Merged/Unmerged Branches, Tags
3. **Dateianalyse** — Blame, Dateihistorie, umbenannte/gelöschte Dateien
4. **Suche** — Hash, Commit-Message, Autor, Pickaxe, Regex
5. **Stash** — Stash-Liste, Stash-Detail
6. **Eigene Commits** — Zeitraum-Filter nach Autor
7. **Statistiken** — Hotspot-Dateien, Commit-Frequenz, Wochentag/Stunde-Verteilung
8. **Reports & Export** — PR-Summary, Changelog-Generator (feat/fix/chore → Markdown)

---

## Installation

```bash
git clone https://github.com/drapatzc/toolbox.git
cd toolbox
```

Im Stammverzeichnis des Xcode-Projekts starten:

```bash
cd MeinXcodeProjekt
../toolbox/toolbox
```

---

*Entwickelt von Christian Drapatz · macOS 13+*
