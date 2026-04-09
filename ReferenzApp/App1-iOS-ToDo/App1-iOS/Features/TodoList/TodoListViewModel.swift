import Foundation
import Observation

/// ViewModel für die Listenansicht aller Todos.
/// Koordiniert Datenabruf und Benutzeraktionen über den Service.
@Observable
final class TodoListViewModel {

    // MARK: - Zustand

    private(set) var todos: [Todo] = []
    var isAddTodoPresented: Bool = false

    // MARK: - Abhängigkeiten

    private let service: TodoServiceProtocol

    init(service: TodoServiceProtocol) {
        self.service = service
    }

    // MARK: - Öffentliche Aktionen

    func loadTodos() {
        todos = service.loadTodos()
    }

    func toggleCompletion(of todo: Todo) {
        service.toggleCompletion(of: todo)
        loadTodos()
    }

    func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            service.deleteTodo(id: todos[index].id)
        }
        loadTodos()
    }

    func showAddTodo() {
        isAddTodoPresented = true
    }
}
