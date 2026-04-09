import Testing
import Foundation
@testable import App2_MacOS

/// Tests für den AppStore.
struct AppStoreTests {

    private func makeSUT(initialTasks: [WorkTask] = []) -> (store: AppStore, persistence: MockPersistence) {
        let persistence = MockPersistence()
        persistence.tasksToLoad = initialTasks
        let store = AppStore(persistence: persistence)
        return (store, persistence)
    }

    // MARK: - Initialisierung

    @Test("Store lädt Tasks beim Start aus der Persistenz")
    func storeLoadsTasksOnInit() {
        let task = WorkTask(title: "Persistierter Task")
        let (store, _) = makeSUT(initialTasks: [task])
        #expect(store.state.tasks.count == 1)
        #expect(store.state.tasks.first?.title == "Persistierter Task")
    }

    @Test("Initialer State hat korrekten Standardwert")
    func initialStateHasCorrectDefaults() {
        let (store, _) = makeSUT()
        #expect(store.state.selectedTaskID == nil)
        #expect(store.state.filterStatus == nil)
        #expect(store.state.isAddTaskPresented == false)
        #expect(store.state.errorMessage == nil)
    }

    // MARK: - Dispatch

    @Test("Dispatch einer Aktion aktualisiert den State")
    func dispatchingActionUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(title: "Neuer Task", description: "", priority: .medium))
        #expect(store.state.tasks.count == 1)
        #expect(store.state.tasks.first?.title == "Neuer Task")
    }

    @Test("Dispatch speichert Tasks in der Persistenz")
    func dispatchSavesTasksToPersistence() {
        let (store, persistence) = makeSUT()
        store.dispatch(.addTask(title: "Test", description: "", priority: .low))
        #expect(persistence.saveCallCount > 0)
        #expect(persistence.lastSavedTasks.count == 1)
    }

    @Test("Mehrere Dispatches stapeln sich korrekt")
    func multipleDispatchesStackCorrectly() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(title: "Erste", description: "", priority: .high))
        store.dispatch(.addTask(title: "Zweite", description: "", priority: .low))
        #expect(store.state.tasks.count == 2)
    }

    @Test("showAddTask aktualisiert State über Dispatch")
    func showAddTaskUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.showAddTask)
        #expect(store.state.isAddTaskPresented == true)
    }

    @Test("Löschen eines Tasks aktualisiert Persistenz")
    func deletingTaskUpdatesPersistence() {
        let task = WorkTask(title: "Zu löschen")
        let (store, persistence) = makeSUT(initialTasks: [task])
        store.dispatch(.deleteTask(id: task.id))
        #expect(persistence.lastSavedTasks.isEmpty)
    }

    @Test("Reducer-Fehler (leerer Titel) landet im State")
    func reducerErrorLandsInState() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(title: "  ", description: "", priority: .medium))
        #expect(store.state.errorMessage != nil)
        #expect(store.state.tasks.isEmpty)
    }
}
