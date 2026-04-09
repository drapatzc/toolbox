import Foundation

/// Abstrahiert den Datenzugriff für Todo-Elemente.
/// Ermöglicht das einfache Austauschen der Persistenzschicht (z. B. InMemory ↔ CoreData).
protocol TodoRepositoryProtocol: AnyObject {
    /// Gibt alle gespeicherten Todos chronologisch sortiert zurück.
    func fetchAll() -> [Todo]

    /// Speichert ein neues Todo.
    func save(_ todo: Todo)

    /// Aktualisiert ein bestehendes Todo.
    func update(_ todo: Todo)

    /// Löscht das Todo mit der angegebenen ID.
    func delete(id: UUID)
}
