import Foundation

/// In-Memory-Implementierung der Persistenzschicht.
/// Speichert Tasks nur im Arbeitsspeicher – ideal für Tests und Prototypen.
final class InMemoryPersistence: PersistenceProtocol {

    private var tasks: [WorkTask] = []

    func loadTasks() -> [WorkTask] {
        tasks
    }

    func saveTasks(_ tasks: [WorkTask]) {
        self.tasks = tasks
    }
}
