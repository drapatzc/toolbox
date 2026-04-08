# Release Notes — Xcode Developer Toolbox

---

## Version 1.0.4 — 2026-04-08

### Verbesserungen: Test-Menü (TestPlan & Test-Schema)

- **Vollständige TestPlan-Erkennung** — TestPläne werden nun nicht mehr nur aus dem aktuell gewählten Schema gelesen, sondern bei Bedarf aus allen `.xcscheme`-Dateien des gesamten Projekts. Findet das aktuelle Schema keinen TestPlan, durchsucht das Tool alle anderen Schemas und zeigt die gefundenen Pläne mit ihrem Herkunfts-Schema an (z.B. `MyData  [bitone-MyData]`). Bei Auswahl wird das Test-Schema automatisch gewechselt, sodass xcodebuild den richtigen Plan findet.

- **Automatischer Schema-Wechsel beim TestPlan** — Wird ein TestPlan aus einem anderen Schema gewählt, setzt das Tool `selectedTestScheme` auf das besitzende Schema. xcodebuild erhält damit das korrekte Schema+TestPlan-Kombination. Der Header zeigt `📋 MyData  [bitone-MyData]`, damit der Wechsel sichtbar bleibt.

- **Korrekter Pre-Check für deaktivierte Test-Targets** — Der Test-Vorab-Check zählte bisher alle `TestableReference`-Einträge im Schema, auch deaktivierte (`skipped="YES"`). Diese werden nun korrekt herausgefiltert — ein Schema mit ausschließlich deaktivierten Test-Targets wird korrekt als „keine Tests vorhanden" erkannt.

- **Hinweis bei `test-without-building`** — Vor dem Ausführen von Option 5 erscheint jetzt ein Hinweis, dass zuvor ein `build-for-testing`-Lauf (Option 4) erforderlich ist.

- **Hinweis wenn TestPlan aktiv** — Bei Unit-Tests, UI-Tests, Coverage und `test-without-building` erscheint eine Info-Meldung, wenn ein TestPlan aktiv ist: der Plan überschreibt die Test-Target-Liste des Schemas vollständig.

- **Warnung bei UI-Tests auf macOS-Ziel** — Wenn das aktuell gewählte Ziel `platform=macOS` ist, erscheint beim Start von UI-Tests eine Warnung, da UI-Tests in der Regel einen Simulator benötigen.

- **Korrekte Plattformerkennung bei Test-Schema** — `detectSchemePlatforms()` und damit `buildDestination()` lesen die Plattform jetzt aus dem effektiven Test-Schema (`effectiveTestScheme()`), nicht mehr aus dem Build-Schema. Dadurch ist die `-destination` bei abweichendem Test-Schema immer korrekt.

- **Schema-Dateisuche aus Projektverzeichnis** — Die Suche nach `.xcscheme`-Dateien erfolgt nun vom übergeordneten Projektverzeichnis aus (nicht mehr innerhalb des Workspace-Bundles). Damit werden auch Schemas in eingebetteten `.xcodeproj`-Dateien zuverlässig gefunden.

### Neue Funktionen: Header

- **Menü ein-/ausblenden** — Die Kopfzeile lässt sich nun per Tastendruck ein- und ausklappen. Taste `-` reduziert die Anzeige auf Systeminfo (Xcode, Swift, Projekt, Branch); Taste `+` blendet alle Einstellungszeilen wieder ein. Der Zustand wird persistent in `~/.xcode_toolbox_prefs.json` gespeichert, der Standard ist ausgeklappt. Die Versionzeile zeigt jeweils `[-] Reduzieren` bzw. `[+] Erweitern` als Hinweis. Ein Reset setzt den Zustand auf den Standard (ausgeklappt) zurück. Die Hilfe des Hauptmenüs enthält einen entsprechenden Hinweis.

- **Branch-Anzeige auf eigener Zeile** — Projekt und Branch werden nun auf separaten Zeilen angezeigt, damit lange Branch-Namen das Rechteck nicht mehr zerstören.
- **Automatische Kürzung langer Branch-Namen** — Ist ein Branch-Name zu lang für die Breite des Headers, wird er von links gekürzt und mit `...` eingeleitet. Das Ende des Branch-Namens bleibt dabei immer sichtbar (z.B. `...ios-wla-bankverbindung-dialog-unbekannter-fehler-zfa`).

### Verbesserungen: TestPlan-Auswahl

- **TestPläne aus dem Dateisystem** — Die TestPlan-Auswahl (`T`) findet nun zusätzlich alle `.xctestplan`-Dateien im Projektverzeichnis, die nicht in einem `.xcscheme` referenziert sind. Diese erscheinen in der Auswahlliste in einer separaten Gruppe mit `📁 Nur Datei`-Badge. Beim Auswählen eines solchen Plans bleibt das aktuelle Test-Schema unverändert.

- **Darstellung an Xcode angeglichen** — Die TestPlan-Auswahlliste wurde grundlegend überarbeitet:
  - Scheme-registrierte Pläne werden mit einem blauen **■** App-Icon dargestellt.
  - Sub-Testpläne (auf Disk vorhanden, nicht im Scheme) zeigen ein gelbes **⚙** Zahnrad-Icon — wie Xcodes Scheme-Picker.
  - Trennlinie zwischen beiden Gruppen.
  - Sub-Testpläne sind vollständig ausführbar (xcodebuild findet sie per Name im Projektverzeichnis), genau wie in Xcode.
  - Pläne ohne existierende Datei werden nicht angezeigt.
  - **Bugfix**: CI-UnitTest erschien doppelt, weil der XML-Parser auch `BuildActionEntry`-Referenzen auswertete. Der Parser sucht nun ausschließlich in `<TestAction><TestPlans>`. Zusätzliche Deduplizierung innerhalb eines Schemes verhindert doppelte Einträge bei mehrfach referenzierten Plänen.

### Bugfixes & UX

- **Doppelte Leerzeile vor Eingabe-Prompt behoben** — In mehreren Menüs (Extended-Hauptmenü, Standard-Hauptmenü, Einstellungen) erschienen zwei Leerzeilen zwischen dem letzten Menüeintrag und dem `▶ Auswahl:`-Prompt. Ursache war ein überflüssiges `print()` direkt vor `readMenuChoice()`, das nun entfernt wurde.

---

## Version 1.0.3 — 2026-04-08

### Fehlerbehebungen

- **TestPlan-Unterstützung korrigiert** — Die in Version 1.0.2 eingeführte Unterstützung für Xcode-TestPläne wurde überarbeitet und korrigiert. In der vorherigen Version gab es noch einen Fehler bei der Erkennung bzw. Verwendung von TestPlänen in bestimmten Projekt- und Scheme-Konstellationen. Dieses Verhalten wurde in Version 1.0.3 behoben, sodass TestPläne nun zuverlässiger verarbeitet werden.

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
