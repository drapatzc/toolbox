import Foundation

/// Alle möglichen Aktionen, die den Anwendungszustand verändern können.
/// Im Redux-Muster werden Aktionen an den Store dispatcht, der den Reducer aufruft.
enum AppAction: Equatable {
    case addTask(title: String, description: String, priority: TaskPriority)
    case updateTaskStatus(id: UUID, newStatus: TaskStatus)
    case deleteTask(id: UUID)
    case selectTask(id: UUID?)
    case setFilter(status: TaskStatus?)
    case showAddTask
    case hideAddTask
    case clearError
}
