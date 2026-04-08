import SwiftUI

/// Detailansicht für die aktuell ausgewählte Aufgabe.
struct TaskDetailView: View {

    let store: AppStore

    var body: some View {
        if let task = store.state.selectedTask {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    metadataSection(for: task)
                    if !task.taskDescription.isEmpty {
                        descriptionSection(for: task)
                    }
                    statusSection(for: task)
                }
                .padding(24)
            }
            .navigationTitle(task.title)
            .navigationSubtitle(task.status.rawValue)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        store.dispatch(.deleteTask(id: task.id))
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                    .help("Aufgabe löschen")
                    .accessibilityIdentifier("deleteTaskButton")
                }
            }
        }
    }

    // MARK: - Abschnitte

    private func metadataSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Priorität: \(task.priority.rawValue)", systemImage: "flag.fill")
                .foregroundStyle(task.priority.displayColor)
                .font(.subheadline)
            Label(
                "Erstellt: \(task.createdAt.formatted(date: .long, time: .omitted))",
                systemImage: "calendar"
            )
            .foregroundStyle(.secondary)
            .font(.subheadline)
        }
    }

    private func descriptionSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Beschreibung")
                .font(.headline)
            Text(task.taskDescription)
                .foregroundStyle(.secondary)
        }
    }

    private func statusSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status ändern")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) {
                        store.dispatch(.updateTaskStatus(id: task.id, newStatus: status))
                    }
                    .buttonStyle(.bordered)
                    .tint(task.status == status ? Color.accentColor : nil)
                    .accessibilityIdentifier("statusButton_\(status.rawValue)")
                }
            }
        }
    }
}

// MARK: - Erweiterungen

private extension TaskPriority {
    var displayColor: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
