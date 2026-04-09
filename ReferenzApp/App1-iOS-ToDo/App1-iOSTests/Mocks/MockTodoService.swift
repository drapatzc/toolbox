import Foundation
@testable import App1_iOS

/// Test-Double für den TodoService.
/// Erlaubt das Testen von ViewModels ohne echte Geschäftslogik.
final class MockTodoService: TodoServiceProtocol {

    // MARK: - Gespeicherte Aufrufe

    private(set) var toggledTodoIDs: [UUID] = []
    private(set) var deletedIDs: [UUID] = []
    private(set) var createCallCount: Int = 0

    // MARK: - Konfigurierbarer Zustand

    var storedTodos: [Todo] = []
    var createShouldThrow: Bool = false

    // MARK: - TodoServiceProtocol

    func loadTodos() -> [Todo] {
        storedTodos
    }

    func createTodo(title: String) throws -> Todo {
        createCallCount += 1
        if createShouldThrow {
            throw TodoError.emptyTitle
        }
        let todo = Todo(title: title)
        storedTodos.append(todo)
        return todo
    }

    func toggleCompletion(of todo: Todo) {
        toggledTodoIDs.append(todo.id)
    }

    func deleteTodo(id: UUID) {
        storedTodos.removeAll { $0.id == id }
        deletedIDs.append(id)
    }
}
