# Release Notes — Xcode Developer Toolbox

---

## Version 1.0.2 — 2026-04-08

### Neue Funktionen

- **TestPlan-Unterstützung im Test-Menü** — Das Tool unterstützt nun zwei unterschiedliche Test-Verfahren, die über die Taste `T` ausgewählt werden:
  - **Test-Schema** — Separates Test-Target als eigenes Scheme (z.B. `TargetATest`). xcodebuild verwendet das gewählte Schema direkt.
  - **TestPlan** — Xcode-TestPlan (`.xctestplan`) der direkt aus der Scheme-Datei des aktuellen Schemas gelesen wird. Bei nur einem verknüpften TestPlan wird dieser automatisch übernommen, bei mehreren erscheint eine Auswahlliste mit Markierung des Default-Plans. xcodebuild erhält das Flag `-testPlan 'Name'`.
  - Beide Einstellungen schließen sich gegenseitig aus — das Setzen des einen löscht das andere automatisch.

- **Visuelles Icon im Header** — Die Zeile `[T]` zeigt drei unterschiedliche Icons je nach Zustand:
  - `⬜` — noch kein Test-Ziel gewählt
  - `🧪` — Test-Schema aktiv
  - `📋` — TestPlan aktiv

---

## Version 1.0.1 — 2026-04-07

### Neue Funktionen

- **Onboarding-Tour** — Beim ersten Programmstart wird automatisch eine mehrseitige interaktive Einführung angezeigt (7 Seiten: Willkommen, Leistungsübersicht, Bedienung, Hauptbereiche, Alltagsworkflow, Benutzerdefiniertes Menü & Hotkeys, Abschluss). Vollständig lokalisiert in allen 17 Sprachen.

- **Neues Menü: Sicherheit & Datenschutz (22)** — Acht Analysefunktionen (read-only) für sicherheitsrelevante Projektbereiche:
  - ATS-Konfiguration prüfen (`NSAppTransportSecurity`)
  - App-Berechtigungen prüfen (`NS*UsageDescription`)
  - Info.plist-Sicherheitscheck
  - Secrets-Scan (API-Keys, Tokens, Passwörter im Quellcode)
  - Hardcodierte IPs finden (IPv4 / IPv6)
  - Entitlements-Übersicht (`.entitlements`)
  - Privacy Manifest prüfen (`PrivacyInfo.xcprivacy`)
  - xcconfig-Dateien analysieren

- **Neues Menü: CI/CD & Tools Integration (23)** — 15 Aktionen rund um Continuous Integration und Entwicklungswerkzeuge:
  - **GitHub Actions** (via `gh` CLI): Runs auflisten, PR-Status, PR-Liste, Workflows auflisten, Run beobachten
  - **Fastlane**: Lanes anzeigen, Lane ausführen (kontextabhängig — nur wenn Fastfile vorhanden)
  - **Tuist** und **XcodeGen**: Projektgenerierung (kontextabhängig — nur wenn Konfigurationsdatei vorhanden)
  - **Git Worktrees**: Auflisten, Hinzufügen, Entfernen
  - **Conventional Commits**: Commit-Assistent, nächste semantische Version ermitteln, `.gitignore` prüfen

- **Projekt-Analyse erweitert** — Das Menü „Projekt-Analyse" (08) enthält nun 35 read-only Analysen, u.a. Swift-Dateianzahl & LOC, Code-Struktur (Klassen/Structs/Enums/Protokolle), Dateitypübersicht, Deployment-Target, Test-Ratio und mehr.

- **SPM-Abhängigkeiten auflösen** — Vor der Schema-Auswahl werden Swift Package Manager-Abhängigkeiten automatisch aufgelöst (`xcodebuild -resolvePackageDependencies`). Neue Aktion auch im benutzerdefinierten Menü verfügbar.

- **Menü "Tests" stark erweitert** — Sechs neue Optionen:
  - Build for Testing (`xcodebuild build-for-testing`)
  - Test without Building (`xcodebuild test-without-building`)
  - Langsame Tests erkennen (aus letztem `.xcresult`)
  - JUnit-Report generieren (→ `Desktop/junit_report.xml`)
  - Markdown-Testbericht erstellen (→ `Desktop/TestReport.md`)
  - Dateien ohne Testabdeckung anzeigen

- **Ausgabe-Modus im Test-Menü** — Bei den Optionen 1–5 (Unit Tests, UI Tests, Coverage, Build for Testing, Test without Building) kann vor der Ausführung zwischen zwei Ausgabe-Modi gewählt werden:
  - **Build-Ausgabe** — rohe `xcodebuild`-Ausgabe live mit Build-Zusammenfassung (Fehler/Warnungen gruppiert)
  - **Test-Ausgabe** — gefilterte Darstellung mit ✅/❌ pro Test und kompakter Zusammenfassung

- **Menü "Clean" überarbeitet** — Strukturierte Übersicht mit nummerierten Löschen/Anzeigen-Paaren für alle Cache-Typen (DerivedData, Modules, Module-Cache, SPM-Cache u.a.) sowie `xcodebuild clean` und kombinierte Lösch-Optionen.

- **Benutzerdefiniertes Menü erweitert** — Viele neue zuweisbare Aktionen:
  - SPM-Abhängigkeiten auflösen
  - SwiftLint und Periphery direkt ausführbar
  - Simulator: App installieren, App starten (Bundle-ID), Push-Benachrichtigung senden, und weitere Simulator-Aktionen

- **Neuer Menü-Modus: Standard (ohne Beta)** — Vierter wählbarer Hauptmenü-Modus (`M`-Shortcut). Zeigt alle stabilen Untermenüs des Standard-Menüs (01–10: Clean, Build & Simulator, Test, Code-Qualität, Projekt-Analyse, Metriken, Git, Xcode verwalten, Info & Diagnose, Apps öffnen). Beta-markierte Bereiche (Sicherheit, CI/CD, Simulator Extended) werden ausgeblendet — ideal für den stabilen Alltagsbetrieb ohne experimentelle Funktionen.

### Verbesserungen

- **Beta-Kennzeichnung in der Komplett-Ansicht** — Beta-Untermenüs (z.B. Physische Geräte, Dependencies, CI/CD, Sicherheit u.a.) sind in der Komplett-Ansicht jetzt wie im Standard-Menü mit einem grünen `(Beta-Version)`-Tag gekennzeichnet.

- **Icons im Menü** — Alle Menüeinträge haben jetzt visuelle Icons für eine bessere Übersichtlichkeit. Untermenü-Einträge (führen zu einem Untermenü) sind mit 📁 gekennzeichnet. Befehle/Aktionen erhalten ein einheitliches ◆-Symbol. Abschnitts-Überschriften innerhalb der Menüs haben jeweils ein thematisch passendes Icon (z.B. 🔨 für Build, 🧪 für Tests, 🔒 für Sicherheit, 📦 für Abhängigkeiten).

- **Simulator Extended erweitert** — Neue Aktionen: App installieren, App starten (Bundle-ID), Logs anzeigen, installierte Apps auflisten, Push-Benachrichtigung testen, Deep-Link öffnen, Berechtigungen setzen, Medien hinzufügen, App-Datenordner öffnen, Video-Aufzeichnung, Status-Bar mocken/zurücksetzen, SQLite-DB finden, Group-Container öffnen u.v.m.

- **Hauptmenü strukturiert** — Zwei neue Sektionen „Sicherheit & CI/CD" mit den neuen Menüs 22 (Sicherheit) und 23 (CI/CD).

- **Benutzerdefiniertes Menü vorbelegt** — Beim ersten Start werden Standardeinträge automatisch befüllt (`populateDefaultCustomMenuIfNeeded()`).

- **Arbeitsverzeichnis-Browser neu gestaltet** — Der tastaturgesteuerte Verzeichnis-Navigator wurde vollständig überarbeitet und nutzt nun den einheitlichen `FileBrowser` mit verbessertem Rendering und Filtermöglichkeiten nach Dateiendung.

- **Mehrsprachigkeit** — 14 neue Sprachen hinzugefügt: Arabisch, Dänisch, Spanisch, Finnisch, Französisch, Italienisch, Japanisch, Koreanisch, Niederländisch, Portugiesisch, Russisch, Schwedisch, Türkisch, Chinesisch (vereinfacht & traditionell). Das Sprachmenü (`L`) listet alle verfügbaren Sprachen automatisch aus der Lokalisierungsdatei.

- **Lokalisierung erweitert** — Ca. 430 neue Lokalisierungskeys für alle neuen Funktionen (DE + EN + alle neuen Sprachen).

---

## Version 1.0.0 — 2026-04-06

### Initiale Veröffentlichung

Erstes Release des Xcode Developer Toolbox CLI-Tools für iOS/macOS-Entwickler.

**Enthaltene Funktionen:**

- Tastaturgesteuertes Terminal-Menü (Simple- und Extended-Modus)
- Build & Run (Simulator und macOS nativ)
- Tests ausführen (Unit Tests)
- Clean (DerivedData, Caches)
- Code-Qualität: SwiftLint, SwiftFormat (Dry-Run), Periphery, Static Analyzer
- Metriken & Projekt-Analyse
- Simulator-Verwaltung (Install, Launch, Push-Notifications, Screenshots u.v.m.)
- Benutzerdefiniertes Menü mit frei konfigurierbaren Aktionen
- Einstellungen: Import, Export, Zurücksetzen
- Arbeitsverzeichnis-Auswahl mit persistenten Einstellungen (`~/.xcode_toolbox_prefs.json`)
- Vollständige DE/EN-Lokalisierung
- Globale Keyboard-Shortcuts (Schema, Device, Config, Bundle-ID, Sprache, Hilfe u.a.)
- Integriertes Hilfesystem
