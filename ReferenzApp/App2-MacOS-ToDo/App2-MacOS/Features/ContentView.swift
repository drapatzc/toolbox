import SwiftUI

/// Hauptansicht der macOS-App: NavigationSplitView mit Aufgabenliste und Detailbereich.
struct ContentView: View {

    let store: AppStore

    var body: some View {
        NavigationSplitView {
            TaskListView(store: store)
        } detail: {
            if store.state.selectedTask != nil {
                TaskDetailView(store: store)
            } else {
                emptyDetailView
            }
        }
        .sheet(isPresented: Binding(
            get: { store.state.isAddTaskPresented },
            set: { _ in store.dispatch(.hideAddTask) }
        )) {
            AddTaskView(store: store)
        }
        .frame(minWidth: 700, minHeight: 450)
    }

    // MARK: - Leer-Zustand Detailbereich

    private var emptyDetailView: some View {
        ContentUnavailableView(
            "Keine Aufgabe ausgewählt",
            systemImage: "checklist",
            description: Text("Wähle eine Aufgabe aus der Liste oder erstelle eine neue mit ⌘N.")
        )
    }
}
