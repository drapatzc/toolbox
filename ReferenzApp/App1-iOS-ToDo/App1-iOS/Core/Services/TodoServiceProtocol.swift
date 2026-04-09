import Foundation

/// Definiert die Geschäftslogik für das Verwalten von Todos.
/// Sitzt zwischen ViewModel und Repository und kapselt Validierungsregeln.
protocol TodoServiceProtocol: AnyObject {
    /// Lädt alle Todos aus dem Repository.
    func loadTodos() -> [Todo]

    /// Erstellt ein neues Todo nach Validierung des Titels.
    /// - Parameter title: Der Titel des neuen Todos (darf nicht leer sein).
    /// - Throws: `TodoError.emptyTitle` wenn der Titel leer ist.
    func createTodo(title: String) throws -> Todo

    /// Wechselt den Erledigungsstatus eines Todos.
    func toggleCompletion(of todo: Todo)

    /// Löscht das Todo mit der angegebenen ID.
    func deleteTodo(id: UUID)
}

// MARK: - Fehlertypen

/// Fehlertypen für die Todo-Geschäftslogik.
enum TodoError: LocalizedError, Equatable {
    case emptyTitle

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Der Titel darf nicht leer sein."
        }
    }
}
