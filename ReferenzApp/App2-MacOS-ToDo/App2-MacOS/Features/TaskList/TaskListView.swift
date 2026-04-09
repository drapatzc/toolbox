import SwiftUI

/// Seitenleiste der macOS-App: zeigt alle Aufgaben mit Filter- und Sortierfunktion.
struct TaskListView: View {

    let store: AppStore

    var body: some View {
        List(store.state.filteredTasks, selection: Binding(
            get: { store.state.selectedTaskID },
            set: { store.dispatch(.selectTask(id: $0)) }
        )) { task in
            TaskRowView(task: task)
                .tag(task.id)
        }
        .listStyle(.sidebar)
        .navigationTitle("Aufgaben")
        .toolbar {
            ToolbarItemGroup {
                filterMenuButton
                addTaskButton
            }
        }
        .accessibilityIdentifier("taskList")
        .overlay {
            if store.state.filteredTasks.isEmpty {
                emptyStateView
            }
        }
    }

    // MARK: - Toolbar-Elemente

    private var addTaskButton: some View {
        Button(action: { store.dispatch(.showAddTask) }) {
            Label("Neue Aufgabe", systemImage: "plus")
        }
        .accessibilityIdentifier("addTaskButton")
        .help("Neue Aufgabe anlegen (⌘N)")
    }

    private var filterMenuButton: some View {
        Menu {
            Button("Alle anzeigen") {
                store.dispatch(.setFilter(status: nil))
            }
            Divider()
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button(status.rawValue) {
                    store.dispatch(.setFilter(status: status))
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
        .help("Aufgaben filtern")
    }

    // MARK: - Leer-Zustand

    private var emptyStateView: some View {
        ContentUnavailableView(
            "Keine Aufgaben",
            systemImage: "tray",
            description: Text("Erstelle eine neue Aufgabe mit ⌘N.")
        )
    }
}

// MARK: - Task-Zeile

/// Einzelne Zeile in der Aufgaben-Seitenleiste.
private struct TaskRowView: View {

    let task: WorkTask

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                priorityDot
                Text(task.title)
                    .font(.headline)
                    .lineLimit(1)
            }
            Text(task.status.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), Priorität \(task.priority.rawValue), \(task.status.rawValue)")
    }

    private var priorityDot: some View {
        Circle()
            .fill(task.priority.color)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Erweiterungen für Darstellung

private extension TaskPriority {
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
