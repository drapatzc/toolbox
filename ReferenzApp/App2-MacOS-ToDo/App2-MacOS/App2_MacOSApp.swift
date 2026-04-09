import SwiftUI

/// Einstiegspunkt der App2-MacOS-Aufgabenverwaltung.
/// Erzeugt den zentralen AppStore und gibt ihn an die Wurzelansicht weiter.
@main
struct App2_MacOSApp: App {

    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Neue Aufgabe") {
                    store.dispatch(.showAddTask)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
