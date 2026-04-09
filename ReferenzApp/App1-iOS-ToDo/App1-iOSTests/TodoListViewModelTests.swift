import Testing
import Foundation
@testable import App1_iOS

/// Tests für das TodoListViewModel.
struct TodoListViewModelTests {

    private func makeSUT(initialTodos: [Todo] = []) -> (viewModel: TodoListViewModel, service: MockTodoService) {
        let service = MockTodoService()
        service.storedTodos = initialTodos
        let viewModel = TodoListViewModel(service: service)
        return (viewModel, service)
    }

    // MARK: - Laden

    @Test("Todos werden beim Laden korrekt in den Zustand übernommen")
    func todosAreSetOnLoad() {
        let testTodos = [Todo(title: "Erster"), Todo(title: "Zweiter")]
        let (viewModel, _) = makeSUT(initialTodos: testTodos)
        viewModel.loadTodos()
        #expect(viewModel.todos.count == 2)
    }

    @Test("Leere Liste wird bei leerem Service korrekt angezeigt")
    func emptyListIsDisplayedWithEmptyService() {
        let (viewModel, _) = makeSUT()
        viewModel.loadTodos()
        #expect(viewModel.todos.isEmpty)
    }

    // MARK: - Hinzufügen

    @Test("isAddTodoPresented wird beim Tippen auf Hinzufügen true")
    func isAddTodoPresentedBecomesTrue() {
        let (viewModel, _) = makeSUT()
        viewModel.showAddTodo()
        #expect(viewModel.isAddTodoPresented == true)
    }

    // MARK: - Status wechseln

    @Test("Toggle ruft Service auf und lädt Todos neu")
    func toggleCallsServiceAndReloadsTodos() {
        let todo = Todo(title: "Zu toggeln")
        let (viewModel, service) = makeSUT(initialTodos: [todo])
        viewModel.loadTodos()
        viewModel.toggleCompletion(of: todo)
        #expect(service.toggledTodoIDs.contains(todo.id))
    }

    // MARK: - Löschen

    @Test("Löschen von Todos ruft Service korrekt auf")
    func deletingTodosCallsService() {
        let testTodos = [Todo(title: "Zu löschen")]
        let (viewModel, service) = makeSUT(initialTodos: testTodos)
        viewModel.loadTodos()
        viewModel.deleteTodos(at: IndexSet([0]))
        #expect(service.deletedIDs.count == 1)
    }

    @Test("Nach dem Löschen werden Todos neu geladen")
    func todosAreReloadedAfterDeletion() {
        let (viewModel, service) = makeSUT(initialTodos: [Todo(title: "Test")])
        viewModel.loadTodos()
        service.storedTodos = [] // Service löscht intern
        viewModel.deleteTodos(at: IndexSet([0]))
        #expect(viewModel.todos.isEmpty)
    }
}
