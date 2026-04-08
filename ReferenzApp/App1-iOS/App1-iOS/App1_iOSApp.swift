import SwiftUI

/// Einstiegspunkt der App1-iOS-App.
/// Richtet den Dependency-Container ein und startet die Hauptansicht.
@main
struct App1_iOSApp: App {

    var body: some Scene {
        WindowGroup {
            TodoListView(viewModel: DependencyContainer.shared.makeTodoListViewModel())
        }
    }
}
