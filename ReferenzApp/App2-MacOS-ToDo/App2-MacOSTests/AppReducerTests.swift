import Testing
import Foundation
@testable import App2_MacOS

/// Tests für die reine Reducer-Funktion.
/// Da der Reducer eine reine Funktion ist, können alle Fälle ohne Mocks getestet werden.
struct AppReducerTests {

    // MARK: - addTask

    @Test("Aufgabe wird korrekt hinzugefügt")
    func taskIsAddedCorrectly() {
        let state = AppState()
        let action = AppAction.addTask(title: "Neue Aufgabe", description: "Beschreibung", priority: .high)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.count == 1)
        #expect(newState.tasks.first?.title == "Neue Aufgabe")
        #expect(newState.tasks.first?.taskDescription == "Beschreibung")
        #expect(newState.tasks.first?.priority == .high)
        #expect(newState.tasks.first?.status == .todo)
        #expect(newState.isAddTaskPresented == false)
        #expect(newState.errorMessage == nil)
    }

    @Test("Leerer Titel setzt Fehlermeldung und fügt keine Aufgabe hinzu")
    func emptyTitleSetsErrorMessageAndNoTaskAdded() {
        let state = AppState()
        let action = AppAction.addTask(title: "   ", description: "", priority: .medium)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.isEmpty)
        #expect(newState.errorMessage != nil)
    }

    @Test("Titel wird beim Hinzufügen bereinigt")
    func titleIsTrimmedOnAdd() {
        let state = AppState()
        let action = AppAction.addTask(title: "  Aufgabe  ", description: "", priority: .low)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.title == "Aufgabe")
    }

    // MARK: - updateTaskStatus

    @Test("Aufgabenstatus wird korrekt aktualisiert")
    func taskStatusIsUpdatedCorrectly() {
        var state = AppState()
        let task = WorkTask(title: "Test", status: .todo)
        state.tasks = [task]

        let action = AppAction.updateTaskStatus(id: task.id, newStatus: .inProgress)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.status == .inProgress)
    }

    @Test("Update auf nicht vorhandene ID hat keine Auswirkung")
    func updateNonExistentTaskHasNoEffect() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Vorhandene Aufgabe")]
        let action = AppAction.updateTaskStatus(id: UUID(), newStatus: .done)
        let newState = appReducer(state: state, action: action)
        #expect(newState.tasks.first?.status == .todo)
    }

    // MARK: - deleteTask

    @Test("Aufgabe wird korrekt gelöscht")
    func taskIsDeletedCorrectly() {
        var state = AppState()
        let task = WorkTask(title: "Zu löschen")
        state.tasks = [task]
        state.selectedTaskID = task.id

        let action = AppAction.deleteTask(id: task.id)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.isEmpty)
        #expect(newState.selectedTaskID == nil)
    }

    @Test("Löschen einer anderen Aufgabe löscht die Auswahl nicht")
    func deletingOtherTaskKeepsSelection() {
        var state = AppState()
        let selectedTask = WorkTask(title: "Ausgewählt")
        let otherTask = WorkTask(title: "Anderer")
        state.tasks = [selectedTask, otherTask]
        state.selectedTaskID = selectedTask.id

        let action = AppAction.deleteTask(id: otherTask.id)
        let newState = appReducer(state: state, action: action)

        #expect(newState.selectedTaskID == selectedTask.id)
    }

    // MARK: - selectTask

    @Test("Aufgabe wird korrekt ausgewählt")
    func taskIsSelectedCorrectly() {
        let state = AppState()
        let taskID = UUID()
        let newState = appReducer(state: state, action: .selectTask(id: taskID))
        #expect(newState.selectedTaskID == taskID)
    }

    @Test("Auswahl wird mit nil zurückgesetzt")
    func selectionIsResetWithNil() {
        var state = AppState()
        state.selectedTaskID = UUID()
        let newState = appReducer(state: state, action: .selectTask(id: nil))
        #expect(newState.selectedTaskID == nil)
    }

    // MARK: - setFilter

    @Test("Filter wird korrekt gesetzt")
    func filterIsSetCorrectly() {
        let state = AppState()
        let newState = appReducer(state: state, action: .setFilter(status: .done))
        #expect(newState.filterStatus == .done)
    }

    @Test("Filter wird mit nil zurückgesetzt")
    func filterIsResetWithNil() {
        var state = AppState()
        state.filterStatus = .done
        let newState = appReducer(state: state, action: .setFilter(status: nil))
        #expect(newState.filterStatus == nil)
    }

    // MARK: - showAddTask / hideAddTask

    @Test("showAddTask setzt isAddTaskPresented auf true")
    func showAddTaskSetsFlag() {
        let state = AppState()
        let newState = appReducer(state: state, action: .showAddTask)
        #expect(newState.isAddTaskPresented == true)
    }

    @Test("hideAddTask setzt isAddTaskPresented auf false")
    func hideAddTaskClearsFlag() {
        var state = AppState()
        state.isAddTaskPresented = true
        let newState = appReducer(state: state, action: .hideAddTask)
        #expect(newState.isAddTaskPresented == false)
    }

    // MARK: - clearError

    @Test("clearError entfernt die Fehlermeldung")
    func clearErrorRemovesErrorMessage() {
        var state = AppState()
        state.errorMessage = "Ein Fehler ist aufgetreten"
        let newState = appReducer(state: state, action: .clearError)
        #expect(newState.errorMessage == nil)
    }
}
