import Foundation
@testable import App2_MacOS

/// Test-Double für die Persistenzschicht.
/// Erlaubt das Testen des Stores ohne echte Datenspeicherung.
final class MockPersistence: PersistenceProtocol {

    // MARK: - Gespeicherte Aufrufe

    private(set) var saveCallCount: Int = 0
    private(set) var lastSavedTasks: [WorkTask] = []

    // MARK: - Konfigurierbarer Zustand

    var tasksToLoad: [WorkTask] = []

    // MARK: - PersistenceProtocol

    func loadTasks() -> [WorkTask] {
        tasksToLoad
    }

    func saveTasks(_ tasks: [WorkTask]) {
        lastSavedTasks = tasks
        saveCallCount += 1
    }
}
