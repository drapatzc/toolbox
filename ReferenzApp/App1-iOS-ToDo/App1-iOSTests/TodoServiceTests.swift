import Testing
import Foundation
@testable import App1_iOS

/// Tests für die TodoService-Geschäftslogik.
struct TodoServiceTests {

    private func makeSUT() -> (service: TodoService, repository: MockTodoRepository) {
        let repository = MockTodoRepository()
        let service = TodoService(repository: repository)
        return (service, repository)
    }

    // MARK: - Laden

    @Test("Todos werden korrekt aus dem Repository geladen")
    func todosAreLoadedFromRepository() {
        let (service, repository) = makeSUT()
        repository.storedTodos = [Todo(title: "Vorhanden")]
        let todos = service.loadTodos()
        #expect(todos.count == 1)
        #expect(todos.first?.title == "Vorhanden")
    }

    // MARK: - Erstellen

    @Test("Neues Todo wird mit bereinigtem Titel gespeichert")
    func newTodoIsSavedWithTrimmedTitle() throws {
        let (service, repository) = makeSUT()
        let todo = try service.createTodo(title: "  Mein Todo  ")
        #expect(todo.title == "Mein Todo")
        #expect(repository.savedTodos.count == 1)
        #expect(repository.savedTodos.first?.title == "Mein Todo")
    }

    @Test("Leerer Titel wirft TodoError.emptyTitle")
    func emptyTitleThrowsTodoError() {
        let (service, _) = makeSUT()
        #expect(throws: TodoError.emptyTitle) {
            try service.createTodo(title: "   ")
        }
    }

    @Test("Nur-Leerzeichen-Titel wirft Fehler")
    func whitespaceOnlyTitleThrowsError() {
        let (service, _) = makeSUT()
        #expect(throws: TodoError.emptyTitle) {
            try service.createTodo(title: "\n\t ")
        }
    }

    @Test("Valider Titel erzeugt Todo ohne Fehler")
    func validTitleCreatesTodoWithoutError() throws {
        let (service, _) = makeSUT()
        let todo = try service.createTodo(title: "Valider Titel")
        #expect(todo.title == "Valider Titel")
        #expect(todo.isCompleted == false)
    }

    // MARK: - Status wechseln

    @Test("Erledigungsstatus wird über Repository aktualisiert")
    func completionStatusIsToggledViaRepository() {
        let (service, repository) = makeSUT()
        let todo = Todo(title: "Toggle Test", isCompleted: false)
        repository.storedTodos = [todo]
        service.toggleCompletion(of: todo)
        #expect(repository.updatedTodos.count == 1)
        #expect(repository.updatedTodos.first?.isCompleted == true)
    }

    // MARK: - Löschen

    @Test("Todo wird korrekt über Repository gelöscht")
    func todoIsDeletedViaRepository() {
        let (service, repository) = makeSUT()
        let todoID = UUID()
        service.deleteTodo(id: todoID)
        #expect(repository.deletedIDs.contains(todoID))
    }
}
