import Testing
import Foundation
@testable import App2_MacOS

/// Tests für berechnete Eigenschaften des AppState.
struct AppStateTests {

    // MARK: - filteredTasks

    @Test("Ohne Filter werden alle Tasks zurückgegeben")
    func allTasksReturnedWithoutFilter() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Erster", status: .todo),
            WorkTask(title: "Zweiter", status: .done)
        ]
        #expect(state.filteredTasks.count == 2)
    }

    @Test("Filter nach Status gibt nur passende Tasks zurück")
    func filterByStatusReturnsMatchingTasksOnly() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Offen", status: .todo),
            WorkTask(title: "Erledigt", status: .done),
            WorkTask(title: "In Arbeit", status: .inProgress)
        ]
        state.filterStatus = .todo
        #expect(state.filteredTasks.count == 1)
        #expect(state.filteredTasks.first?.title == "Offen")
    }

    @Test("Leere Liste bei passendem Filter gibt leeres Array zurück")
    func emptyResultForNonMatchingFilter() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Offen", status: .todo)]
        state.filterStatus = .done
        #expect(state.filteredTasks.isEmpty)
    }

    // MARK: - Sortierung

    @Test("filteredTasks sortiert nach Priorität (Hoch zuerst)")
    func filteredTasksSortsByPriorityHighFirst() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Niedrig", priority: .low),
            WorkTask(title: "Hoch", priority: .high),
            WorkTask(title: "Mittel", priority: .medium)
        ]
        let sorted = state.filteredTasks
        #expect(sorted[0].title == "Hoch")
        #expect(sorted[1].title == "Mittel")
        #expect(sorted[2].title == "Niedrig")
    }

    // MARK: - selectedTask

    @Test("selectedTask gibt nil zurück wenn keine ID gesetzt ist")
    func selectedTaskReturnsNilWithoutSelection() {
        let state = AppState()
        #expect(state.selectedTask == nil)
    }

    @Test("selectedTask gibt nil zurück wenn ID nicht vorhanden ist")
    func selectedTaskReturnsNilForUnknownID() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Vorhandener Task")]
        state.selectedTaskID = UUID() // unbekannte ID
        #expect(state.selectedTask == nil)
    }

    @Test("selectedTask gibt den korrekten Task zurück")
    func selectedTaskReturnsCorrectTask() {
        var state = AppState()
        let task = WorkTask(title: "Ausgewählter Task")
        state.tasks = [WorkTask(title: "Anderer"), task]
        state.selectedTaskID = task.id
        #expect(state.selectedTask?.id == task.id)
        #expect(state.selectedTask?.title == "Ausgewählter Task")
    }
}
