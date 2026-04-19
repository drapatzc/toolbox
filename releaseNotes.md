# Release Notes — Xcode Developer Toolbox

---

## Version 1.0.12 — 2026-04-19

### Project Manager & Terminal Stability

- **New feature: Project Manager** — Three new actions in the main menu under "🔧 Project Manager": `Initialize project` (clones repositories from a JSON configuration into a purely temporary directory), `Update project` (discards local changes and re-pulls), and `Delete project` (removes repositories and state entry). Full logic in `ActionProjectManager.swift` (~1000 lines). Read-only against the remote — no commits, no pushes. State is persisted per JSON configuration in `.toolbox-project-state.json`. Integrated into the Main, Simple, Slim, and Complete-Tree menus; entries are shown/hidden dynamically via `canShowProjectInit` / `canShowProjectUpdateOrDelete`. Example config: `repository-scanbox.json` (replaces the former `repository-toolbox.json`).

- **Submodule support in the Project Manager** — The Project Manager now supports Git submodules and subtrees in cloned repositories. The optional JSON field `submodule_branch_strategy` controls how submodules are handled when switching branches or commits: `"follow_parent"` (default) switches all submodules to the same branch as the main repository, `"pinned"` leaves submodules at their Git-pinned commit, and an explicit branch name switches all submodules to exactly that branch. The switch is performed via `git submodule foreach --recursive`; if a branch does not exist in a submodule, it stays on its pinned commit (no abort). The "Show project info" action has been extended with a new "Submodules / Subtrees" section that explains all three strategies.

- **Simulator boot blocks until ready** — `bootDevice()` now waits via `xcrun simctl bootstatus -b` after `simctl boot` until the simulator is fully booted. Fixes a race condition where `simctl install` was rejected while the simulator was still in the "Booting" state.

- **Device name & OS in status messages** — `bootDevice()` and `installAndLaunchApp()` now also accept `deviceName` and `deviceOS`; status messages now show concrete text like "Starting iPhone 17 Pro — iOS 26.1" instead of a generic "Starting simulator".

- **New function `runShellInteractive()`** — Inherits stdin/stdout/stderr directly from the terminal; required for shell commands that prompt for a password or passphrase (e.g. `git clone` over SSH with a protected key). `runShellLive` additionally recognises `\r` as a line terminator and suppresses empty lines.

- **Stable ESC sequence handling** — `FileBrowser` and `MenuGitBrowser` now read arrow keys via `VTIME=1` (100 ms timeout per follow-up byte) instead of `fcntl(O_NONBLOCK)`. Prevents occasionally ignored or misinterpreted arrow key sequences.

- **Spinner: cursor hide/show** — `ActivitySpinner` hides the cursor at start with ANSI `\u{1B}[?25l` and restores it at stop with `\u{1B}[?25h`; each line is now explicitly cleared (`\u{1B}[2K`) before the frame is drawn instead of only at line end.

- **`waitForKeyPress()` flow centralised** — At the end of `actionBuildAndRunSimulator`, `actionStartAppOnly`, `actionStartAppOnSelectedSimulator`, `actionFullResetAndBuild`, and `actionQuickResetAndBuild`, `waitForKeyPress()` is now invoked exactly once — instead of depending on `isMacOSDevice` inside an `if/else` branch. A `flushInputBuffer()` before the multi-simulator loop prevents keyboard buffer from a previous action from skipping the `[+]` prompt.

### Tests

- **3-state test result classification** — Previously the tool only distinguished between "passed" and "failed". From now on three states are clearly separated:

  - ✅ **Success** — All tests passed, no technical error.
  - ⚠️ **Technical Failure** — `xcodebuild` reported `** TEST FAILED **`, but no actual test case failed (e.g. empty test target, missing test plan configuration, compiler error). The result is highlighted in yellow; a hint text explains the difference from real test failures.
  - ❌ **Real Failures** — At least one test case actually failed. Red border as before.

- **`TestRunOutcome` enum** — New enum with three cases: `.success`, `.technicalFailure`, and `.realFailures`. The `outcome` property on `TestRunData` derives the state from the set flags and counters.

- **`testFailed` flag in `TestRunData`** — New `Bool` field: set when `xcodebuild` outputs `** TEST FAILED **` — regardless of whether real test cases failed.

- **`printTestResultBox()` and `printTestSummary()` reworked** — Both functions now use a `switch data.outcome` instead of a simple `if/else`. Technical failures get their own yellow box with a hint message.

- **Live parsing: `runTestsLive()` detects `** TEST FAILED **`** — The live parser now sets `data.testFailed` when `xcodebuild` emits this marker.

- **Auto-Build: technical failure logged separately** — In the Auto-Build cycle (`AutoBuildActions.swift`), the `.technicalFailure` state is now logged with ⚠ and a hint — separately from real test failures.

- **Timeline evaluation unified** — `currentTimeline?.endPhase(success:)` in `MenuTest.swift` and `AutoBuildActions.swift` now uses `outcome == .success` instead of the previous manual multi-condition check (`testSucceeded && failed.isEmpty && !buildFailed`).

### Build Output

- **Grouped, structured build output** — The new `XcodeBuildFormatter` presents `xcodebuild` output structured by phases (Compile, Link, Copy, Sign, …). Each phase is clearly separated; copy resource operations show the individual file name (`extractCopyResourceName()`).

- **Build formatter: target in phase headers** — `showTargetForPhase()` and `extractTargetFromPhaseLine()` now display the build target in relevant phase headers. `printStep()` uses `▸` instead of `→` for clearer visual separation.

### Input & Interaction

- **`[x]` as unified back key** — `[x]` works in all menus and dialogs without a trailing Enter — one key press to go back. Affected: `waitForKeyPress`, `DeviceSelector`, `SimulatorActions`.

- **`confirmAction()` reacts immediately** — Confirmations with `j`/`J`/`y`/`Y` and cancellations with `n`/`N` are processed instantly — no Enter press required.

- **Simulator loops: `[+]` without Enter** — In the multi-simulator loop, `[+]` starts the next simulator immediately, without pressing Enter.

- **`readRawChar()` and `readDeviceSelection(max:)`** — New input functions for immediate single-character shortcuts; `readDeviceSelection` processes numeric selections directly without Enter.

- **Bug fix: duplicate `waitForKeyPress()` in MenuTest** — The duplicate call in `case "1"` (Unit Tests) has been fixed.

- **Test menu numbers revised** — The entries in the test menu have been renumbered.

- **"Tests with Code Coverage" and "Detect slow tests" removed from menu display** — Both items are no longer listed in the menu; the functionality is preserved in the code.

- **Localization keys updated** — All changed labels updated in 17 languages.

- **Live SPM package list during resolution** — While `xcodebuild -resolvePackageDependencies` runs, all packages are updated with live status indicators (○ pending / ⠋ loading / ✓ done / ✗ failed). The ActivitySpinner shows the package name during Fetch/Clone.

- **`actionCancelled` flag and "Cancelled" message** — After declining a `confirmAction()` prompt, `waitForKeyPress()` returns immediately — no extra key press needed. A unified cancellation message is shown.

- **ActivitySpinner for cache and DerivedData operations** — `printStep()` replaced by ActivitySpinner for all cache/DerivedData deletions. `printCtrlCHint()` now appears before the operation starts. `xcodebuild clean` uses `runXcodebuildLiveFormatted`.

- **`readDeviceSelection()` switched to `readLine()`** — Raw mode no longer needed.

- **New color `Color.boldDarkPurple`** — Used consistently for [RETURN] hints in all input prompts. New localization keys: `spm_resolve_retry`, `start_build_run_confirm`, `action_cancelled`.

### Dependencies

- **CocoaPods: Live install/update list** — `runPodsInstallWithLiveList()`: `pod install` and `pod update` show all pods with live status indicators. New action: show Podfile.lock (`actionPodsShowPodfileLock()`).

- **Carthage: Live update list and new actions** — `runCarthageWithLiveList()` shows all frameworks with live status during `carthage update`/`bootstrap`. New actions: show Cartfile.resolved, Bootstrap (`actionCarthageBootstrap()`), update frameworks (`actionCarthageUpdateFrameworks()`).

- **Subspec filter** — CocoaPods subspecs (e.g. `GRDB.swift/standard`, `Moya/Core`) are no longer listed in the dependency display — only the top-level name appears.

- **Thread-safe spinner** — `var spinnerRunning` replaced with a `SpinnerFlag` reference type; fixes Swift Sendable warning on thread closure capture.

### Bug Fixes

- **Parameterised Swift Testing tests** — `runTestsLive()` and `parseTestData()` now recognise the format of parameterised Swift Testing tests without quotes (e.g. `◇ Test decode_succeeds(input: TestInput(...)) passed after 0.001 seconds.`). Previously such tests were silently ignored — result counters remained empty.

### Example Configurations (Project Manager)

- **HTTPS example configurations added** — Two new example JSON configurations for the Project Manager have been added to the `work/HTTPS/` folder: `repository-cliTools.json` (clones the xcodex and toolbox repositories via HTTPS) and `repository-refApps.json` (clones the RefenzApps repository via HTTPS). Both SSH (`work/SSH/`) and HTTPS variants of all example configurations are now available.

### Reference Apps

- **New reference app App11-iOS-Namensliste-U-UI** — iOS app for managing a name list (MVVM, SwiftUI, LiquidGlass extension). Includes unit tests, UI tests, and a complete test plan.

- **New reference app App15-iOS-Dependencies-spm-cocoapods-carthage** — iOS app with 15 dependencies split across all three package managers: 7 via SPM (Nuke, MarkdownUI, Defaults, swift-dependencies, swift-collections, swift-log, SnapshotTesting), 5 via CocoaPods (Lottie, Alamofire, Moya, GRDB.swift, Factory), 3 via Carthage (Kingfisher, DGCharts, AppAuth). Each dependency belongs exclusively to one package manager.

---

## Version 1.0.11 — 2026-04-15

### Bug Fixes

- **Build (compile only) fixed for macOS** — An incorrect `isMacOSDevice` guard in `actionBuildDebug()` was unconditionally blocking macOS builds, even though `xcodebuild build` with `-destination 'platform=macOS'` works correctly. The guard has been removed. "Build" is now available for iOS Simulator, iPadOS Simulator, and macOS (My Mac) alike.

- **Duplicate DerivedData directory for macOS fixed** — Two `xcodebuild -showBuildSettings` calls in `SchemeSelector.swift` (bundle ID reading and `detectSchemePlatforms()`) were missing the `-derivedDataPath` flag. On macOS, `xcodebuild` internally resolves packages when querying build settings and writes to the default DerivedData location — this does not occur with the iOS Simulator. Both calls now include `-derivedDataPath '\(toolboxProductBuildPath)'`.

- **Bug fix: "Uninstall app & fresh test"** — If no `.app` file is found in the product-specific build folder, the tool now asks whether the app should be built right away. Confirming starts `actionBuildAndRunSimulator()` directly. Previously only an error message was shown with no further action.

### UI & UX

- **Consistent action headers for shortcut dialogs** — `printActionHeader()` is now used consistently for all global keyboard shortcut dialogs: configuration (`K`), language (`L`), menu mode (`M`), scheme (`S`), and device (`D`). All these dialogs now show the same structured title/description block as regular menu actions.

- **`[A]` workflow: fewer key presses** — When switching the working directory (`A`), scheme and test target selection are now embedded without a trailing `waitForKeyPress()`. The intermediate confirmation is skipped; the flow proceeds directly to device selection.

- **`selectBuildScheme()` / `selectTestTarget()` with new parameters** — Both functions now accept `showHeader: Bool` and `suppressFinalWait: Bool`. This allows them to be cleanly embedded in higher-level workflows (e.g. `[A]`) without showing their own header or final pause.

### Build & App Path Display

- **Build path shown after a successful build** — After every successful build, the tool now shows which folder the app was placed in (`printBuiltAppInfo()`). Affected actions: "Build", "Build & Run", "Quick Reset & Build", and "Full Reset & Build".

- **App path shown on launch** — When launching the app directly (actions "Launch App" and "Relaunch App"), the full path of the started `.app` file is printed.

### Tests

- **`printTestSummary()` removed** — In all test actions (Unit Tests, UI Tests, All Tests, Coverage, JUnit Report, Markdown Report, test plan runs), results are now shown exclusively via `printTestResultBox()`. The redundant summary line has been removed.

- **`BuildTimeline` per simulator iteration** — In the multi-simulator loop, `BuildTimeline.begin/finish` is now called correctly for each additional simulator run. Previously, the timeline was not restarted when switching to an additional simulator.

- **`build-for-testing` and `test-without-building` unified** — Both actions now use `runBuildLive()` and `runTestsLiveParsed()` respectively and display the same result box as all other test actions. `askOutputMode()` has been removed — output is now consistent across all test actions.

- **macOS targets** — Test actions running on macOS (`platform=macOS`) now correctly wait for a key press instead of attempting a simulator shutdown.

### Dependencies

- **SPM — "Show Package.resolved": action header added** — The action now shows a structured title and description block (`printActionHeader()`). New localization key `spm_show_package_resolved_description` added in all 17 languages.

### Display

- **`printBuiltAppInfo()` cleaned up** — ANSI color codes have been removed from the app info box border lines. The app path is now shown on a dedicated line below the label — better readability for long paths and neutral across different terminal color themes.

---

## Version 1.0.10 — 2026-04-14

### DerivedData Precision

- **Targeted deletion applied consistently** — Every place in the code that cleans DerivedData has been reviewed and updated. From now on, only the product-specific folder (`DerivedData/{product}`) is ever deleted — the full DerivedData directory is never wiped automatically. The only exception remains deliberate clean actions where the user explicitly confirms a full delete.

- **Affected areas:** Directory change, configuration switch (Debug↔Release), Full Reset & Build, Auto-Build clean levels, and SPM SourcePackages.

### xcodebuild — Consistent Use of `-derivedDataPath`

- **`-derivedDataPath` set everywhere** — All xcodebuild calls that produce build artefacts now consistently pass `-derivedDataPath` with the product-specific folder. Affected areas: static analysis, profiling builds, build timing analysis, and archive. All intermediate artefacts now land in the same place.

### Dependencies

- **CocoaPods — Show Dependencies** — New action in the CocoaPods section: parses `Podfile.lock` and displays all installed pods with name and version in a consistent format.

- **Carthage — Show Dependencies** — New action in the Carthage section: parses `Cartfile.resolved` and displays all installed frameworks with name, version, and source URL in a consistent format.

### Display Fixes

- **Double path prefix fixed** — Several display texts were showing the path as `DerivedData/DerivedData/ToolboxBuild-…`. The root cause (a doubled prefix in localisation keys) has been corrected; the path now displays correctly as `DerivedData/{product}`.

- **Description texts updated** — All confirmation prompts and description texts (17 languages) have been corrected: they now accurately describe the app build folder instead of vague phrases such as "all caches will be deleted".

- **Quick Reset & Build** — The confirmation prompt no longer shows the folder path redundantly, since it is already visible in the description box.

### Behaviour

- **Quit behaviour changed** — Lowercase `q` no longer exits the app. Only uppercase `Q` quits. A lowercase `q` is ignored and the input prompt reappears.

### Bug Fixes

- **Duplicate DerivedData directory fixed (resolvePackageDependencies)** — All `xcodebuild -resolvePackageDependencies` calls were missing the `-derivedDataPath` flag. Xcode therefore created a second default DerivedData directory alongside the product-specific folder. All seven affected locations have been corrected.

- **`-archivePath` correctly quoted** — The value was passed without quotes. Scheme names containing spaces caused shell word-splitting, which broke the archive action. Fixed: `-archivePath '…'`.

---

## Version 1.0.9 — 2026-04-13

### Build Acceleration

- **Build speed flags added** — Up to four parameters are now passed during the build (`COMPILER_INDEX_STORE_ENABLE=NO`, `ONLY_ACTIVE_ARCH=YES`, and in Debug mode additionally `DEBUG_INFORMATION_FORMAT=dwarf` and `SWIFT_COMPILATION_MODE=incremental`), noticeably reducing build times.

### DerivedData Optimization

- **Targeted clean instead of full wipe** — DerivedData is no longer deleted entirely. Only the product-specific folder is removed during a clean, making subsequent builds considerably faster.

### Clean, Build, and Test Processes

- **Processes stabilized** — Clean, build, and test workflows were further revised and made more reliable. Automated tests also benefit from the optimizations.

### Test Output

- **JUnit report and Markdown report with full diagram** — The "Generate JUnit Report" and "Markdown Test Report" actions now use the same output style as "Run Unit Tests": filtered live output, class summary, and BuildTimeline diagram.

- **Slow tests: bar chart** — The slow tests display now includes a color-coded bar chart that visualizes test durations proportionally.

- **"Files without tests" progress reworked** — Progress now runs on a single overwriting line and correctly shows the total number of all files checked.

---

## Version 1.0.8 — 2026-04-13

### New Feature: Git Browser

- **Git browser integrated** — New interactive view that makes Git information accessible directly within the tool. Built in two stages, followed by a bug-fix release.

- **Git > Enter user** — The Git username can now be entered and saved directly within the Git section of the tool.

### Platform Detection

- **Platform detection is now persisted** — The "Detect Platform..." action caused long loading times on every call. The result is now cached and only re-evaluated when the scheme or working directory changes.

### Diagrams & UX

- **Diagrams shown without key press** — Build and test timeline diagrams are now displayed immediately after a run, without requiring a key press.

- **UX for commands improved** — Presentation and interaction for menu commands have been revised and unified.

- **Missing menu registrations added** — Several commands were not registered in the menu registry and are now correctly included.

### Tests & Workflow

- **Unit, UI, and automated tests improved** — Existing tests were revised for better stability.

- **"Select working directory" workflow changed** — The process for switching the working directory has been updated.

### Configuration & Localization

- **`senior.conf` updated** — The "senior" configuration has been adapted to the new Git browser and further changes.

- **Localization extended** — Additional strings have been localized; metrics and various UX texts were added.

---

## Version 1.0.7 — 2026-04-12

### Rename: Auto-Build → Live-Build

- **Auto-Build is now Live-Build** — The core feature introduced in 1.0.6 has been renamed consistently throughout the app. All menu entries, settings, log messages, and localization keys are now aligned on "Live-Build". The surrounding menu structure was updated as well so Live-Build is easy to find in its new position.

### New Feature: Build and Test Timeline Diagrams

- **Timeline renderer** — Two new units: `Core/BuildTimeline.swift` (data model) and `Core/BuildTimelineRenderer.swift` (ASCII renderer). After every build or test run, a timeline is drawn that visualizes each Xcode phase as a bar — making it immediately obvious where the time actually went.

- **Integration in the Build and Test menus** — The timeline is emitted automatically in `BuildActions` and `MenuTest`. Live-Build also produces a diagram after each run, in addition to the phase legend introduced in 1.0.6.

- **Fully localized** — All diagram labels, phase abbreviations, and unit strings are available in DE/EN; additional languages were extended where the source strings were accessible.

### Live-Build: Package Manager Integration

- **Package managers fully applied by the script** — Live-Build now takes CocoaPods, Carthage, and Swift Package Manager into account. Before every build/test cycle, the configured package managers are applied in full via script (install / update / resolve), so newly added dependencies no longer have to wait until the following cycle.

- **New file `Actions/PackageManagerSync.swift`** — Encapsulates the package-manager invocation in one place and is called from both `AutoBuildActions` (Live-Build) and `BuildActions`.

### Live-Build: Configurable Clean Mode

- **Clean behavior selectable in settings** — In the Live-Build settings menu you can now choose **how** cleaning happens before every run: no clean, partial derived-data clean, or a full clean. The choice is persisted via `Preferences.swift` alongside the other Live-Build settings and shown on the dashboard.

### Live-Build: Test Plan Support

- **`xcodebuild` test plans are recognized** — Live-Build now explicitly understands test plans (`.xctestplan`). Existing test plans are resolved correctly and used during test runs. Previously, targets with multiple test plans could produce inconsistent results — runs succeeded but attribution stayed empty.

### Custom Menu

- **Two variable columns** — The custom menu now features two variably configurable columns. Column width and the number of entries per column adapt dynamically to the available terminal width and the actual entry count.

### Menu Structure

- **"Dependencies" ↔ "Build & Simulator" order swapped** — The two menus have been swapped in their position within the main menu to better reflect actual usage frequency. Touches `MenuBuildSimulator`, `MenuDependencies`, `MenuCompleteTree`, and the associated `MenuRegistry` entries.

- **Commands renamed** — Various menu and action labels were streamlined and unified. Around 170 localization keys were touched; existing functionality remains unchanged.

### Configuration

- **`senior.conf` updated** — The "senior" configuration has been adapted to the new 1.0.7 menu structure and the renamed commands (Auto-Build → Live-Build and the swapped menu order).

### Localization

- All new Live-Build, timeline, clean-mode, and package-manager strings have been localized (DE + EN, more languages where possible).

---

## Version 1.0.6 — 2026-04-11

### New Feature: Auto-Build

- **Live Mode `[J]`** — Starts a continuously running build and test cycle with a configurable interval (1 minute to 24 hours, or manually via `∞`). The live screen shows a countdown, the last result, and the path to the log file.

- **Interval selection** — 12 levels selectable directly in the menu or adjustable with `[+]`/`[-]` in live mode. Default: 2 hours. The "Off" entry has been removed.

- **Multiple devices & configurations** — Any number of additional devices and build configurations can be defined alongside the base device and base configuration (settings `[E]`). All are listed one below the other in the live screen.

- **Device × configuration matrix** — Every device–configuration combination is built and tested automatically. The total number of combinations is shown in the settings menu.

- **Log file** — A complete log of every run is automatically saved to the Desktop (`AutoBuild_YYYY-MM-DD_HH-mm-ss.txt`). The path is shown in the live screen and in the menu; `[F]` opens the file in Finder.

### New Feature: Build Timing — Phase Legend

- **Xcode phase legend** — After the total time in the "Build with Timing Report" menu, a legend of all phase abbreviations is now displayed: `Ld` (Linker), `CompileSwift`, `CompileC / ObjC`, `CompileAssetCatalog`, `CodeSign`, `PhaseScript`, `GenerateDSYMFile`, `MergeSwiftModule`, `Validate`, `Process`, `Copy`, `Touch`. Fully localized.

### Architecture & Refactoring

- **`AppContext`** — All mutable app state has been moved into a dedicated `AppContext` class. Global computed properties in `State.swift` forward all accesses transparently — existing code remains unchanged.

- **`UIDashboard`** — Dashboard rendering extracted into its own file.

- **`MenuRegistry`** — Central menu item registry for consistent tracking of all displayed entries.

- **`XCResultParser`** — xcresult parsing extracted into its own unit.

- **New specializations** — `ProjectValidator`, `TestPlanResolver`, `ShellPatterns`.

- **Menus split further** — `MenuCodeQuality`, `MenuMetrics`, `MenuProjectAnalysis`, `MenuCI`, `MenuCodeQualityActions_Classic`, `MenuCodeQualityActions_SwiftLint`, `MenuCodeQualityActions_SwiftUI`, and others.

### Bug Fixes & Improvements

- **Test parser: Swift Testing / Parallel Runner format** — The test result parser now recognizes the lowercase format used by the parallel runner and Swift Testing framework (`Test suite`, `Test case` with slash separator `Suite/testName()`). Previously "Tests examined: 0" was shown even though all tests ran correctly.
  - New helper function `xcbTestSuite()` extracts the suite name directly from the test case line — correct attribution even when multiple test classes run in parallel.

- **Auto-Build: interval default after reset** — After resetting settings, `autoBuildIntervalHours` was incorrectly set to `0.0` (invalid), causing no interval to appear as active. After reset, the default value of **2 hours** is now correctly restored.
  - Safety net in `loadPreferences()`: if an invalid value ≤ 0 is loaded on startup, the 2-hour default kicks in automatically. The state "no interval set" can no longer occur.

### Menus Released from Beta

- **Four menus have left Beta** — After extensive testing, the following submenus are now part of the stable feature set and no longer marked with `(Beta)`: **Binary Analysis**, **Security & Privacy**, **Dependencies**, and **Version Management**. They are available in both the simple and the extended main menu.

### Menu Structure

- **Simple ↔ Extended swapped (`M`)** — The order of the two main menu modes has been swapped. What used to be **M2 (Simple)** is now **M1**, and the previous **M1 (Extended)** is now **M2**. This matches the "Simple first" default for new users.

- **Dependencies menu reworked** — Swift Package Manager packages are now listed directly under the Dependencies menu alongside CocoaPods and Carthage. Each package manager has its own structured section with list, resolve, update, and clean actions. The main menu was also restructured to surface Dependencies as a first-class menu.

- **`MenuCompleteTree`** — New dedicated tree renderer for the complete menu overview, used to print the full menu hierarchy in a single, consistent format.

### Auto-Build: Test Class Detection

- **No false failures for targets without tests** — Auto-Build now checks whether the selected test target actually contains any test classes before running `xcodebuild test`. If no test classes exist, the run is no longer reported as failed — only the pure build result is used. Previously, Auto-Build would mark an otherwise green run as broken whenever `xcodebuild test` had nothing to execute.

### Header Layout

- **Header revised** — Spacing, line breaks, and the position of the settings block in the header have been reworked for a cleaner overall look. Existing collapse/expand behavior (`[-]`/`[+]`) is preserved.

### Security & Keychain

- **`kSecAttrAccessibleAfterFirstUnlock`** — All Keychain entries written by the toolbox (username / Git author) and by the reference apps now use the `kSecAttrAccessibleAfterFirstUnlock` accessibility class, so the entries become available after the first device unlock following a reboot.

### New Reference Apps

- **App8-iOS-xcworkspace** — New reference implementation as a fully fledged `.xcworkspace` with an embedded project. Used to demonstrate workspace handling, scheme/destination detection, and multi-project builds. The app is runnable with its unit tests; the build settings have been reviewed and trimmed to a minimal working configuration.

- **App8-cocoapods** — Reference app for the CocoaPods workflow, used to exercise `Podfile` resolution and the Dependencies → CocoaPods view.

- **App9-spm** — Reference app for Swift Package Manager, used to verify SPM resolution, listing, and updating from the new Dependencies → SPM view.

- **App10-carthage** — Reference app for Carthage, used to verify the Carthage integration flow supported by the Dependencies menu.

### Homepage

- **Brand-new project homepage** at [toolbox.betterlocale.com](https://toolbox.betterlocale.com) — The site has been fully redesigned in a clean Apple-inspired style. The previous version has been archived in the repository.
  - **SEO** — Open Graph, Twitter Card, multi-type JSON-LD (SoftwareApplication / WebSite / Person), canonical URL, `hreflang`, `robots.txt`, `sitemap.xml`, and a dedicated `og-image.svg` social card.
  - **Animations** — Terminal typing cycle, count-up hero stats with `easeOutCubic`, scroll progress bar, hero gradient drift, card tilt/glow on hover.
  - **Smart language detection** — Language is chosen in order: `?lang=` URL parameter → `localStorage` → browser language (`de` → DE, everything else → EN).

### Configuration & Scripts

- **`senior.conf` updated** — The pre-built "senior" configuration profile has been updated to reflect the new menu structure and the four newly released menus.

- **`build.sh` / `copy.sh`** — Both deployment scripts now additionally copy `README_DE.md` alongside `README_EN.md` into the target directory.

- **README files extended** — Both `README_DE.md` and `README_EN.md` now contain new sections for the project **Homepage**, **Support the developer** (PayPal), and **Developer** (Portfolio, AI apps, Games, Apps) — matching the new homepage layout.

- **Repository cleanup** — Unused legacy files have been removed from the repository to reduce clone size.

### Localization

- All new Auto-Build strings and phase descriptions localized (DE + EN, all 17 languages where possible).

### Reference App BKKAtomium (App7)

- **Static Analyzer demo** — New file `Utilities/InsuranceCalculator.swift` with 8 intentional analyzer findings as a test baseline for the Toolbox analyzer integration: Dead Store, Force Cast, Force Unwrap, unreachable code after `return`, memory leak (`UnsafeMutablePointer` without `deallocate()`), always-true condition (`UInt >= 0`), redundant nil comparison, and `== ""` instead of `.isEmpty`.

- **BIC validation tests corrected** — `"TOOSHORT"` (8 characters, valid BIC format) was incorrectly expected to fail, causing a test failure. Replaced with actually invalid values (5, 6, 9 and 10 characters). Outdated BIC `DRESDEFF` (Dresdner Bank, no longer active) replaced with `BELADEBE` (Berliner Sparkasse). Two new positive test cases added.

- **UI Tests: parallel execution disabled** — UI tests were running on 3 simulators simultaneously (`parallelizable = YES`), which could cause race conditions during SwiftData seeding. Now `parallelizable = NO` — sequential execution on a single simulator.

- **Login syntax error fixed** — SourceKit error in `LoginView.swift` caused by a misplaced modifier chain fixed. `.ignoresSafeArea(.keyboard)`, `.onChange` and `.onAppear` correctly moved inside the GeometryReader closure.

---

## Version 1.0.5 — 2026-04-09

### New Features: Goodbye Screen

- **Goodbye screen on exit** — Pressing `Q` now displays a formatted farewell screen (`printGoodbyeScreen()` in `UI.swift`) instead of a single line. The screen contains a localized thank-you message, a feedback note, and links to the official homepage (`https://toolbox.betterlocale.com`), `https://christiandrapatz.de`, `https://betterlocale.com`, and `https://atomiumgames.com`. Called from all menus (main menu, settings, simple menu, etc.).

### New Features: Onboarding

- **Privacy page** — The onboarding tour has been extended with a new page 3 "Privacy & Transparency" (`onboarding_privacy_title`). All previous pages 3–7 have been shifted to 4–8. The tour now contains **8 pages**.

### New Features: Binary Analysis

- **Select app once, remember for all actions** — When opening the binary analysis menu, the app is selected once via the file browser (`pickAppBundle()`). The app name is displayed in the menu header. All nine analyses use the remembered path — no repeated selection per action anymore.

- **New entry [0] "Switch App"** — Allows switching the analyzed app without leaving the menu.

- **Improved app selection** — `pickAppBundle()` sorts newest apps first (via `stat -f '%m'`) and automatically filters out test targets (`*UITests*`, `*Tests-Runner*`, `*XCTest*`).

- **Linked Frameworks redesigned** — Clear separation into two groups: **Custom / Third-Party** (highlighted in yellow, with full path) and **System Frameworks** (dimmed). Count summary at the end.

- **Segment Sizes improved** — Section headers (`▸ Segment`), uniform column width for sections, total line highlighted at the end.

- **Entitlements improved** — Keys are displayed as `▸ Key` headers. `true` shown in green, `false` in red. Structural XML tags (array, dict) are hidden.

- **`printAnalyzedApp()`** — New info block at the beginning of every analysis showing the app name.

### New Features: Distribution & Code Signing

- **IPA Export — File browser for archives** — Instead of manual path entry, a file browser opens directly at `~/Library/Developer/Xcode/Archives`. Only `.xcarchive` bundles are displayed and selectable.

- **IPA Export — Open Finder after export** — After a successful export, the hint `▸ Press + to open Finder` appears. Pressing `+` opens the export folder directly in Finder.

- **Signing identities with expiry date** — Expiry date is read from the Keychain via `security find-certificate | openssl x509 -enddate`. Color-coded display: green (valid), red (expired). Expired certificates are marked with `⚠ expired`.

- **Provisioning Profiles completely rebuilt** — Previously a shell script, now fully implemented in Swift using `PropertyListSerialization`. Each profile shows: name, team, App ID, platform, expiry date. Expired profiles highlighted in red, counter at the end.

### New Features: Simple Menu

- **Extended actions in simple menu** — New items for daily use:
  - `07` — Relaunch app (without new build)
  - `08` — Quick Reset Build (DerivedData → Build → Start)
  - `09` — Run Unit Tests
  - `10` — Run UI Tests
  - `11` — Run All Tests
  - `12` — Stop Simulator
  - `13` — Reset Simulator
  - `14` — Save screenshot to Desktop
  - `15` — Start video recording
  - `16` — Toggle Dark/Light Mode
  - `17` — Close Xcode
  - `18` — Open project in Xcode
  - `19` — Open Apps (submenu)

### Improvements: Simulator Filter

- **Default filter "Available"** — The simulator filter now starts with `"available"` (only available simulators) instead of `"all"`. `[+]` shows all including unavailable ones, `[-]` returns to the available view. The order of hints in the legend has been adjusted accordingly.

### Improvements: Settings

- **Export — Open Finder** — After successfully exporting the settings file to the Desktop, the hint `▸ Press + to open Finder` appears. Pressing `+` opens the Desktop folder in Finder.

### Improvements: Working Directory Selection (A)

- **Guided clean flow on project switch** — After selecting the project file, two new questions are now asked:
  1. "Delete additional caches (without SPM)?" — deletes DerivedData, ModuleCache, CoreSimulator cache, and Xcode cache
  2. "Delete SPM cache?"
  3. SPM resolution: automatically if SPM was deleted, otherwise as an optional question
  The checklist at the beginning shows all five steps.

### Improvements: Clean Menu

- **New item 14 "Guided Clean"** — Interactive step-by-step flow: DerivedData → additional caches → SPM cache → resolve SPM. SPM is automatically re-resolved if the SPM cache was deleted in the previous step.

### Localization

- **Approx. 300 new localization keys** for all new features and texts (all 17 languages).

---

## Version 1.0.4 — 2026-04-09

### New Features: Onboarding

- **Language selection before the tour** — On first launch, a welcome screen with language selection now appears before the actual onboarding tour. All 17 available languages are listed in two columns (with their native names). The selected language is saved immediately and used for all subsequent screens. The active language is marked with `◀`. An empty Enter skips the selection with the current language. The flow is now: **Start → Language Selection → Tour (7 pages) → Main Menu**. A note that the language can be changed at any time in the main menu with `[L]` is included in the welcome text.

### Improvements: Test Menu (TestPlan & Test Scheme)

- **Comprehensive TestPlan detection** — TestPlans are no longer read only from the currently selected scheme, but if needed from all `.xcscheme` files in the entire project. If the current scheme finds no TestPlan, the tool searches all other schemes and displays the found plans with their source scheme (e.g. `MyData  [bitone-MyData]`). When selected, the test scheme is automatically switched so that xcodebuild finds the correct plan.

- **Automatic scheme switch for TestPlan** — If a TestPlan from another scheme is selected, the tool sets `selectedTestScheme` to the owning scheme. xcodebuild then receives the correct scheme+TestPlan combination. The header shows `📋 MyData  [bitone-MyData]` so the switch remains visible.

- **Correct pre-check for disabled test targets** — The test pre-check previously counted all `TestableReference` entries in the scheme, including disabled ones (`skipped="YES"`). These are now correctly filtered out — a scheme with exclusively disabled test targets is correctly recognized as "no tests available".

- **Note for `test-without-building`** — Before executing option 5, a note now appears that a prior `build-for-testing` run (option 4) is required.

- **Note when TestPlan is active** — For unit tests, UI tests, coverage, and `test-without-building`, an info message appears when a TestPlan is active: the plan completely overrides the test target list of the scheme.

- **Warning for UI tests on macOS target** — If the currently selected target is `platform=macOS`, a warning appears when starting UI tests, as UI tests generally require a simulator.

- **Correct platform detection for test scheme** — `detectSchemePlatforms()` and thus `buildDestination()` now read the platform from the effective test scheme (`effectiveTestScheme()`), no longer from the build scheme. This ensures the `-destination` is always correct for a diverging test scheme.

- **Scheme file search from project directory** — The search for `.xcscheme` files now takes place from the parent project directory (no longer inside the workspace bundle). This ensures schemas in embedded `.xcodeproj` files are also reliably found.

### New Features: Header

- **Toggle menu visibility** — The header can now be collapsed and expanded with a keystroke. `-` reduces the display to system info (Xcode, Swift, project, branch); `+` shows all settings lines again. The state is persistently stored in `~/.xcode_toolbox_prefs.json`, the default is expanded. The version line shows `[-] Collapse` and `[+] Expand` respectively as a hint. A reset restores the state to the default (expanded). The main menu help contains a corresponding note.

- **Branch display on its own line** — Project and branch are now displayed on separate lines so that long branch names no longer break the box layout.
- **Automatic truncation of long branch names** — If a branch name is too long for the header width, it is truncated from the left and preceded by `...`. The end of the branch name always remains visible (e.g. `...ios-wla-bankverbindung-dialog-unbekannter-fehler-zfa`).

### Improvements: TestPlan Selection

- **TestPlans from the file system** — The TestPlan selection (`T`) now additionally finds all `.xctestplan` files in the project directory that are not referenced in any `.xcscheme`. These appear in the selection list in a separate group with a `📁 File Only` badge. When such a plan is selected, the current test scheme remains unchanged.

- **Display aligned with Xcode** — The TestPlan selection list has been fundamentally revised:
  - Scheme-registered plans are displayed with a blue **■** app icon.
  - Sub-test plans (present on disk, not in scheme) show a yellow **⚙** gear icon — like Xcode's scheme picker.
  - Divider line between both groups.
  - Sub-test plans are fully executable (xcodebuild finds them by name in the project directory), just like in Xcode.
  - Plans without an existing file are not displayed.
  - **Bugfix**: CI-UnitTest appeared twice because the XML parser also evaluated `BuildActionEntry` references. The parser now searches exclusively in `<TestAction><TestPlans>`. Additional deduplication within a scheme prevents duplicate entries for plans referenced multiple times.

### Improvements: Unit Test Output

- **Build output mode revised** — In the test menu, build output mode (option "1 – Build Output") for unit tests, UI tests, coverage, and test-without-building now uses `runTestsLiveParsed()` + `printTestSummary()` instead of the previous build summary. The output is now structured as:
  - **Build phases** (Init, Resolve, Compile, Link) — displayed once on first occurrence
  - **Passed test classes** — with total count per class (`✓ MyTests  12/12`)
  - **Failed test classes** — with list of failing tests and error messages (`✗ TestName → Error description`)
  - **Unified result banner** (TEST SUCCEEDED / TEST FAILED)

- **TestPlan disk plans via `-only-testing`** — Test plans that are only on disk and not registered in the scheme (`selectedTestPlanIsFromScheme = false`) are now executed with `-only-testing '<Target>'` flags. The target list is read directly from the `.xctestplan` file (`testTargets` array). Only if the file cannot be read does the tool fall back to `-testPlan`. Scheme-registered plans continue to use `-testPlan 'Name'`.

### Bug Fixes & UX

- **Double blank line before input prompt fixed** — In several menus (extended main menu, standard main menu, settings) two blank lines appeared between the last menu entry and the `▶ Selection:` prompt. The cause was a redundant `print()` directly before `readMenuChoice()`, which has now been removed.

### Improvements: Header Display

- **Header width extended to 83 characters** — The inner box width has been increased from 81 to 83 characters so that the URL line is displayed centered with sufficient margin.

- **Title line extended with author credit** — The title now reads `X C O D E   D E V E L O P E R   T O O L B O X   by Christian Drapatz`. The `by Christian Drapatz` addition is displayed in dark gray.

- **URL line instead of copyright text** — The second header line now shows the author's three websites: `https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com`. Displayed in dark gray (`\u{1B}[90m`).

- **New color `darkGray`** — In `Color.swift`, `darkGray` (`\u{1B}[90m`, ANSI Bright Black) has been added as a new constant. The color is equally readable on both light and dark terminal backgrounds.

### New Features: Git Menu

- **Git menu greatly extended** — New analyses and actions:
  - View commits filtered by user (today, yesterday, the day before yesterday, current week, last week, current month, last month)
  - Search in commit messages
  - Search changes to a specific file in Git history
  - Stash management (show, apply, delete)
  - Branch comparison with base branch
  - Repository name is uniformly displayed in all outputs

### New Features: Build & Simulator

- **Build & Simulator menu extended** — Nine new actions:
  - Relaunch app (without new build)
  - Restart / stop simulator (current device)
  - Pre-build checks (SwiftLint + TODO/FIXME scan)
  - Quick Reset Build (delete DerivedData + rebuild)
  - Full Reset Build (all caches + SPM + DerivedData + rebuild)
  - Uninstall and fresh test (Uninstall → Install → Start)
  - Toggle Dark/Light Mode
  - Save screenshot to Desktop

### New Features: Simulator Extended

- **Push notification templates** — 9 predefined payload templates: Simple, Structured (title/subtitle/body), No Sound, Critical, Silent (`content-available`), Badge Only, With Reply Action, Yes/No Action, Custom.

- **Location selection from city list** — Choose simulated GPS location from a predefined city list or enter coordinates manually.

### New Features: Security & Keychain

- **Keychain integration** — The username (Git author) is now securely stored and loaded from the macOS Keychain. On startup, the stored value is automatically applied. No more plain-text storage in the preferences file.

- **Security menu improved** — Additional analyses and display improvements for all eight security checks. Unified header and color-coded status display in all outputs.

### Improvements: Apps & Navigation

- **Open Apps menu** — `Xcodes.app` now appears as the first entry in the Xcode group (before Xcode). New entry "Finder → Project Folder" opens the current project folder directly in Finder — also assignable in the custom menu.

- **Custom menu improved** — New assignable actions (Finder → Project Folder, all new build and simulator actions). Improved overview and slot assignment display.

- **Scheme/Device detection improved** — More reliable detection of schemes and simulators in various project configurations.

- **Localization extended** — Approx. 1100 new localization keys for all new features (all 17 languages).

### New Reference Apps

- **App3-iOS** — Third reference implementation in the `ReferenzApp/` folder. iOS weather app with mocked data, fully documented in German.
  - **Architecture**: MVVM + Service + Repository (identical pattern to App1-iOS)
  - **Data source**: `WeatherSampleRepository` with deterministic sample data for 10 cities (Berlin, Munich, Hamburg, Vienna, Zurich, Paris, London, New York, Tokyo, Sydney)
  - **Features**: City search with filter function, current weather (temperature, humidity, wind, visibility, UV index), 7-day forecast
  - **Unit tests**: 5 test classes with approx. 75 positive and negative tests (Swift Testing Framework), no UI tests
  - **Test plans**: 4 `.xctestplan` files — `AllTests` (default, ⌘U), `RepositoryTests`, `ServiceTests`, `ViewModelTests`

- **App4-iOS-UserManagement** — Fourth reference implementation. iOS app for user management with a local SQLite database (no external dependencies).
  - **Architecture**: MVVM + Service + Repository + Validation
  - **Persistence**: `DatabaseManager` with SQLite directly via C API
  - **Features**: User list, create/edit/delete users, form validation with configurable rules
  - **Unit tests and UI tests** included
  - **Localization**: DE + EN

- **App5-iOS-BeerMaps** — Fifth reference implementation. iOS app for marking beer drinker locations on a map.
  - **Features**: MapKit, Core Location, local push notifications, Keychain (username), drink type selection
  - **Unit tests**: `KeychainService`, `MapViewModel`, `UsernameGenerator`
  - **Localization**: DE + EN

---

## Version 1.0.3 — 2026-04-08

### Bug Fixes

- **TestPlan support corrected** — The TestPlan support introduced in version 1.0.2 has been revised and corrected. In the previous version there was still an error in the detection or use of TestPlans in certain project and scheme constellations. This behavior has been fixed in version 1.0.3 so that TestPlans are now processed more reliably.

---

## Version 1.0.2 — 2026-04-08

### New Features

- **TestPlan support in the test menu** — The tool now supports two different test methods, selectable via the `T` key:
  - **Test Scheme** — Separate test target as its own scheme (e.g. `TargetATest`). xcodebuild uses the selected scheme directly.
  - **TestPlan** — Xcode TestPlan (`.xctestplan`) read directly from the scheme file of the current scheme. If only one linked TestPlan exists, it is automatically applied; if there are multiple, a selection list appears with the default plan marked. xcodebuild receives the flag `-testPlan 'Name'`.
  - Both settings are mutually exclusive — setting one automatically clears the other.

- **Visual icon in the header** — The `[T]` line shows three different icons depending on the state:
  - `⬜` — no test target selected yet
  - `🧪` — test scheme active
  - `📋` — TestPlan active

---

## Version 1.0.1 — 2026-04-07

### New Features

- **Onboarding tour** — On first launch, a multi-page interactive introduction is automatically displayed (7 pages: Welcome, Feature Overview, Controls, Main Areas, Daily Workflow, Custom Menu & Hotkeys, Closing). Fully localized in all 17 languages.

- **New menu: Security & Privacy (22)** — Eight analysis functions (read-only) for security-relevant project areas:
  - Check ATS configuration (`NSAppTransportSecurity`)
  - Check app permissions (`NS*UsageDescription`)
  - Info.plist security check
  - Secrets scan (API keys, tokens, passwords in source code)
  - Find hardcoded IPs (IPv4 / IPv6)
  - Entitlements overview (`.entitlements`)
  - Check Privacy Manifest (`PrivacyInfo.xcprivacy`)
  - Analyze xcconfig files

- **New menu: CI/CD & Tools Integration (23)** — 15 actions around continuous integration and development tools:
  - **GitHub Actions** (via `gh` CLI): list runs, PR status, PR list, list workflows, watch run
  - **Fastlane**: show lanes, run lane (context-sensitive — only when Fastfile is present)
  - **Tuist** and **XcodeGen**: project generation (context-sensitive — only when configuration file is present)
  - **Git Worktrees**: list, add, remove
  - **Conventional Commits**: commit assistant, determine next semantic version, check `.gitignore`

- **Project analysis extended** — The "Project Analysis" menu (08) now contains 35 read-only analyses, including Swift file count & LOC, code structure (classes/structs/enums/protocols), file type overview, deployment target, test ratio, and more.

- **Resolve SPM dependencies** — Before scheme selection, Swift Package Manager dependencies are automatically resolved (`xcodebuild -resolvePackageDependencies`). New action also available in the custom menu.

- **"Tests" menu greatly extended** — Six new options:
  - Build for Testing (`xcodebuild build-for-testing`)
  - Test without Building (`xcodebuild test-without-building`)
  - Detect slow tests (from last `.xcresult`)
  - Generate JUnit report (→ `Desktop/junit_report.xml`)
  - Create Markdown test report (→ `Desktop/TestReport.md`)
  - Show files without test coverage

- **Output mode in test menu** — For options 1–5 (unit tests, UI tests, coverage, build for testing, test without building), two output modes can be selected before execution:
  - **Build Output** — raw `xcodebuild` output live with build summary (errors/warnings grouped)
  - **Test Output** — filtered display with ✅/❌ per test and compact summary

- **"Clean" menu revised** — Structured overview with numbered delete/show pairs for all cache types (DerivedData, Modules, Module Cache, SPM Cache, etc.) as well as `xcodebuild clean` and combined delete options.

- **Custom menu extended** — Many new assignable actions:
  - Resolve SPM dependencies
  - Run SwiftLint and Periphery directly
  - Simulator: install app, launch app (Bundle ID), send push notification, and more simulator actions

- **New menu mode: Standard (without Beta)** — Fourth selectable main menu mode (`M` shortcut). Shows all stable submenus of the standard menu (01–10: Clean, Build & Simulator, Test, Code Quality, Project Analysis, Metrics, Git, Manage Xcode, Info & Diagnostics, Open Apps). Beta-marked areas (Security, CI/CD, Simulator Extended) are hidden — ideal for stable daily use without experimental features.

### Improvements

- **Beta labels in full view** — Beta submenus (e.g. Physical Devices, Dependencies, CI/CD, Security, etc.) are now marked with a green `(Beta)` tag in the full view, just like in the standard menu.

- **Icons in the menu** — All menu entries now have visual icons for better clarity. Submenu entries (leading to a submenu) are marked with 📁. Commands/actions receive a uniform ◆ symbol. Section headings within the menus each have a thematically appropriate icon (e.g. 🔨 for Build, 🧪 for Tests, 🔒 for Security, 📦 for Dependencies).

- **Simulator Extended extended** — New actions: install app, launch app (Bundle ID), show logs, list installed apps, test push notification, open deep link, set permissions, add media, open app data folder, video recording, mock/reset status bar, find SQLite DB, open group container, and much more.

- **Main menu structured** — Two new sections "Security & CI/CD" with new menus 22 (Security) and 23 (CI/CD).

- **Custom menu pre-populated** — On first launch, default entries are automatically filled in (`populateDefaultCustomMenuIfNeeded()`).

- **Working directory browser redesigned** — The keyboard-driven directory navigator has been completely redesigned and now uses the unified `FileBrowser` with improved rendering and filtering by file extension.

- **Multilingual support** — 14 new languages added: Arabic, Danish, Spanish, Finnish, French, Italian, Japanese, Korean, Dutch, Portuguese, Russian, Swedish, Turkish, Chinese (Simplified & Traditional). The language menu (`L`) lists all available languages automatically from the localization file.

- **Localization extended** — Approx. 430 new localization keys for all new features (DE + EN + all new languages).

---

## Version 1.0.0 — 2026-04-06

### Initial Release

First release of the Xcode Developer Toolbox CLI tool for iOS/macOS developers.

**Included features:**

- Keyboard-driven terminal menu (Simple and Extended mode)
- Build & Run (Simulator and macOS native)
- Run tests (Unit Tests)
- Clean (DerivedData, Caches)
- Code quality: SwiftLint, SwiftFormat (Dry-Run), Periphery, Static Analyzer
- Metrics & Project Analysis
- Simulator management (Install, Launch, Push Notifications, Screenshots, etc.)
- Custom menu with freely configurable actions
- Settings: Import, Export, Reset
- Working directory selection with persistent settings (`~/.xcode_toolbox_prefs.json`)
- Full DE/EN localization
- Global keyboard shortcuts (Scheme, Device, Config, Bundle ID, Language, Help, etc.)
- Integrated help system
