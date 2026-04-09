import Foundation

/// Vollständiger, unveränderlicher Anwendungszustand (Single Source of Truth).
/// Im Redux-Muster ist der AppState die einzige Datenquelle der App.
struct AppState: Equatable {

    // MARK: - Datenhaltung

    var tasks: [WorkTask] = []

    // MARK: - Navigations- und UI-Zustand

    var selectedTaskID: UUID?
    var filterStatus: TaskStatus?
    var isAddTaskPresented: Bool = false
    var errorMessage: String?

    // MARK: - Berechnete Eigenschaften

    /// Gibt die gefilterten und nach Priorität sortierten Tasks zurück.
    var filteredTasks: [WorkTask] {
        let filtered: [WorkTask]
        if let filterStatus {
            filtered = tasks.filter { $0.status == filterStatus }
        } else {
            filtered = tasks
        }
        return filtered.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }

    /// Gibt den aktuell ausgewählten Task zurück.
    var selectedTask: WorkTask? {
        guard let selectedTaskID else { return nil }
        return tasks.first { $0.id == selectedTaskID }
    }
}
