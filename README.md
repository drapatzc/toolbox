# Xcode Developer Toolbox

An interactive terminal tool for iOS and macOS developers.  
Combines build, test, simulator, code quality, Git analysis, distribution, and many other developer utilities in a clear keyboard-driven menu — no flag lookups, no context switching.  
The tool is available in **German and English** — switchable at any time without restart.

---

## Why This Tool?

In the daily life of an Apple developer, you constantly switch between Xcode, Terminal, and various CLI tools: `xcodebuild`, `xcrun simctl`, `agvtool`, `otool`, `codesign`, `swiftlint`, `git log` …  
Each tool has its own flags, its own syntax, and its own pitfalls.

**Xcode Developer Toolbox** bundles all of this into a single entry point:

- **No flag lookups** — all common workflows are available as menu items.
- **No context switching** — build, test, clean, analysis, distribution, and Git queries all run in the same terminal.
- **No accidental modifications** — all analysis and Git functions operate **read-only** and modify neither code nor repository.
- **Ready to use immediately** — no external dependencies, runs anywhere Xcode is installed.
- **Your own menu** — assemble a custom menu from 60+ available actions and submenus.

---

## Installation

```bash
git clone https://github.com/drapatzc/toolbox.git
cd toolbox
```

---

## Getting Started

Run the tool in the **root directory of the Xcode project** you want to work with:

```bash
cd MyXcodeProject
../toolbox/toolbox
```

The tool automatically detects `.xcworkspace` or `.xcodeproj` files in the current directory.

### Dashboard Header

Every screen shows a live dashboard at the top with the current context:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  Xcode Developer Toolbox  v01.00.00          Xcode 16.2  Swift 6.0          ║
║  macOS 15.3  Apple M2  16 GB                 MyApp.xcworkspace               ║
║  Scheme: MyApp  ·  Debug  ·  iPhone 16 Pro   User: Christian  ·  EN          ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

All context values (scheme, device, config, user) can be changed at any time via global shortcuts — from any menu, without navigating back.

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Number + Enter | Open menu item |
| `X` | Back to parent menu |
| `Q` | Quit |
| `S` | Select build scheme |
| `T` | Select test scheme |
| `D` | Select device / simulator |
| `K` | Toggle configuration (Debug / Release) |
| `N` | Set Git username |
| `B` | Set bundle ID |
| `C` | Set crash export path |
| `A` | Open interactive directory browser |
| `L` | Change language (DE / EN) |
| `M` | Switch menu mode (Simple / Extended / Custom / Complete) |
| `H` | Context-sensitive help for the current menu |
| `R` | Reset all settings (with confirmation) |

All shortcuts work **from any menu** — no navigation required.

Settings are persistently stored in `~/.xcode_toolbox_prefs.json`.

---

## Menu Modes

Press `M` at any time to switch between four modes:

| Mode | Description |
|------|-------------|
| **Simple** | Compact view with the most important daily tasks — build, run, clean, Git status |
| **Extended** | Full view with all 21 submenus and 200+ actions |
| **Custom** | Your personal menu — freely assembled from 60+ available entries (see below) |
| **Complete** | Tree view showing every menu, submenu, and command at a glance |

---

## Building Your Own Custom Menu

The **Custom Menu** is a personal workspace with up to 20 slots. You choose exactly which actions and submenus appear — assembled once, used every day.

### How It Works

On first launch, the Custom Menu is pre-filled with 7 common defaults. Switch to it with `M` → Custom, or navigate there from the Extended menu.

Press `Z` inside the Custom Menu to open the **Slot Overview** — a numbered list of all 20 slots showing what is assigned, what is empty, and which items are currently unavailable for the active platform.

### Assigning Items

To add an item from the currently visible menu to a slot, type:

```
menu[item]to[slot]
```

**Example:** The Custom Menu shows 5 items. You want to put item 3 into slot 7:

```
menu3to7
```

You can also navigate to any submenu (e.g., the Build menu) and assign items from there to your Custom Menu slots using the same syntax.

> If the target slot is already occupied, the tool shows both the current and the new entry and asks for confirmation before overwriting.

### Managing Slots (Slot Overview — `Z`)

Inside the Slot Overview, the following commands are available:

| Command | Action |
|---------|--------|
| `delete5` | Remove slot 5 (asks for confirmation) |
| `deleteall` | Clear the entire Custom Menu (asks for confirmation) |
| `move3to7` | Move slot 3's content to slot 7 (slot 3 becomes empty) |
| `replace2to5` | Swap the contents of slots 2 and 5 |

### Platform Filtering

Some actions are platform-specific (e.g., Simulator actions are unavailable on macOS-native targets). Unavailable items are shown with a yellow `(unavailable)` marker in the Slot Overview but are automatically hidden from the active Custom Menu — no manual cleanup needed.

### What Can Be Assigned?

The registry contains 60+ entries from all categories:

- Clean & Cache actions (Delete Derived Data, Module Cache, SPM Cache, …)
- Build & Run actions (Build+Run, Quick Reset Build, Launch App, …)
- Test actions (Unit Tests, UI Tests, Coverage Report, …)
- Simulator control (Stop, Screenshot, Dark/Light Mode, Reset, …)
- Physical device actions (Install, Launch, Terminate app, …)
- Git queries (Status, Log, Branch overview, User Commits, …)
- Code quality (SwiftLint, SwiftFormat, Periphery, …)
- Distribution (Export IPA, Notarization check, Release checklist, …)
- All 21 submenus as navigation entries

---

## Help System

Press `H` at any time to open context-sensitive help for the **current menu**. The help panel explains what the menu does, lists available options and commands, and describes any special input syntax.

```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │  Custom Menu — Help                                                     │
  │─────────────────────────────────────────────────────────────────────────│
  │  Your personal menu with up to 20 slots.                               │
  │                                                                         │
  │  Assign items:                                                          │
  │  ▸ menu[n]to[m]  — assign item n from the current menu to slot m       │
  │                                                                         │
  │  Edit slots (Z → Overview):                                             │
  │  ▸ delete[m]     — remove slot m                                        │
  │  ▸ move[x]to[y]  — move slot x to slot y                               │
  │  ▸ replace[x]to[y] — swap slots x and y                                │
  │  ▸ deleteall     — clear the entire menu                               │
  └─────────────────────────────────────────────────────────────────────────┘
```

Each of the 25+ menus has its own help text covering purpose, commands, and tips.

---

## Features

### Development

| Menu | Description |
|------|-------------|
| **Clean & Cache** | Delete Derived Data, Module Cache, Simulator data, and SPM cache — with current disk usage |
| **Build & Simulator** | Build, run, stop simulator, install app, screenshot, toggle Dark/Light Mode, reset |
| **Simulator (Extended)** | App installation, custom launch arguments, log streaming, push notifications, pasteboard |
| **Test** | Unit tests, UI tests, code coverage, JUnit/Markdown reports, slow test detection |
| **Physical Devices** | Install and control apps on real devices via `devicectl` — launch, terminate, list, logs |
| **Dependencies** | SPM, CocoaPods, and Carthage — resolution, cache inspection, package graph |
| **Version Management** | Read and set build number and marketing version via `agvtool` |

### Analysis & Quality

| Menu | Description |
|------|-------------|
| **Code Quality** | SwiftLint (59 checks), SwiftFormat dry-run, Periphery unused code, TODO/FIXME scan |
| **Project Analysis** | 35 read-only analyses: LOC, imports, protocols, class/struct statistics, dependency graphs |
| **Metrics** | Quality score, file complexity, control flow density, UIKit coupling, risk list |
| **Git** | 30+ read-only queries: status, branches, file history, commit search, stash, user commits by date range |
| **Crash & Symbols** | `symbolicatecrash`, `atos`, xcresult evaluation, dSYM verification and metadata |
| **Binary Analysis** | `otool`, `lipo`, `nm`, `strings` for frameworks, architectures, symbols, code signatures |

### Distribution

| Menu | Description |
|------|-------------|
| **Distribution & App Store** | Export IPA, TestFlight upload, notarization check, release checklist validation |
| **Localization** | Check strings files, missing keys, placeholder consistency via `genstrings` |
| **Profiling** | Launch Instruments, analyze build times, inspect cache sizes |
| **XCFramework** | Combine Device + Simulator builds into universal XCFrameworks |
| **Documentation** | Generate, preview, and build DocC; detect undocumented symbols |
| **Certificates & Signing** | Certificates, provisioning profiles, `codesign`, `notarytool` integration |

### System & Tools

| Menu | Description |
|------|-------------|
| **Manage Xcode** | Open, close, restart Xcode; switch active version via `xcode-select` |
| **Directory Browser** | Keyboard-controlled filesystem navigation (arrow keys + Enter) to change working directory |
| **Open Mac Apps** | Quick-launch installed applications by number |
| **Info & Diagnostics** | Disk usage, installed tool versions, running processes, certificates, provisioning profiles |

---

## Requirements

| Requirement | Note |
|-------------|------|
| **macOS** | macOS 13 (Ventura) or later |
| **Xcode** | Including Command Line Tools (`xcode-select --install`) |
| **Swift 5.9+** | Included with Xcode |

### Optional Tools

Some menu items require external tools installable via Homebrew. Without them, those specific functions are skipped — everything else runs without restriction.

```bash
brew install swiftlint     # Code quality: Linting
brew install swiftformat   # Code quality: Formatting
brew install periphery     # Project analysis: Unused code detection
```

---

## Project Structure

```
toolbox/
├── toolbox                   # Executable binary
├── README.md
├── Localizable.xcstrings     # Localization (DE+EN, ~1500 keys)
└── Documentation/
    ├── index.html
    ├── DESCRIPTION.md
    ├── DESCRIPTION.txt
    └── XcodeDeveloperToolbox_Presentation.pptx
```

---

## Technical Implementation

- **Language:** Swift
- **Build System:** Swift Package Manager (SPM), single executable target
- **Platform:** macOS 13+
- **UI:** ANSI escape sequences for colors, progress bars, and spinners — no external UI libraries
- **Persistence:** User settings and custom menu slots as JSON in `~/.xcode_toolbox_prefs.json`
- **Localization:** ~1,500 keys, DE+EN, loaded from `Localizable.xcstrings` at startup
- **Architecture:** Layered design — Core → Project → Actions → Menus; each menu in its own file
- **Safety:** All analysis and Git functions are strictly read-only — no automatic code changes, no Git writes
- **Signal Handling:** `Ctrl+C` safely aborts running operations without quitting the tool
- **No external dependencies** — only Foundation and Xcode Command Line Tools

---

## Author

Christian Drapatz — 2026

---

## License

This project is not published under an open-source license.  
All rights reserved.
