import Foundation

/// Ein einzelner Arbeitsauftrag mit Titel, Beschreibung, Priorität und Status.
struct WorkTask: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var taskDescription: String
    var priority: TaskPriority
    var status: TaskStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .todo,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.priority = priority
        self.status = status
        self.createdAt = createdAt
    }
}

// MARK: - Priorität

/// Prioritätsstufen für Arbeitsaufträge.
enum TaskPriority: String, CaseIterable, Codable {
    case low = "Niedrig"
    case medium = "Mittel"
    case high = "Hoch"

    /// Sortierwert: niedrigerer Wert = höhere Priorität in der Anzeige.
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

// MARK: - Status

/// Bearbeitungsstatus für Arbeitsaufträge.
enum TaskStatus: String, CaseIterable, Codable {
    case todo = "Offen"
    case inProgress = "In Bearbeitung"
    case done = "Erledigt"
}
