import Foundation

/// Abstrahiert die Persistenzschicht für WorkTask-Elemente.
/// Erlaubt den Austausch zwischen InMemory, UserDefaults, CoreData, CloudKit usw.
protocol PersistenceProtocol: AnyObject {
    /// Lädt alle gespeicherten Tasks.
    func loadTasks() -> [WorkTask]

    /// Speichert eine vollständige Liste von Tasks.
    func saveTasks(_ tasks: [WorkTask])
}
