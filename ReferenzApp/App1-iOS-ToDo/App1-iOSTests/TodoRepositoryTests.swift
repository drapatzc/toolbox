import Testing
import Foundation
@testable import App1_iOS

/// Tests für die InMemoryTodoRepository-Implementierung.
struct TodoRepositoryTests {

    private func makeSUT() -> InMemoryTodoRepository {
        InMemoryTodoRepository()
    }

    // MARK: - Leerer Zustand

    @Test("Leeres Repository gibt leere Liste zurück")
    func emptyRepositoryReturnsEmptyList() {
        let sut = makeSUT()
        #expect(sut.fetchAll().isEmpty)
    }

    // MARK: - Speichern

    @Test("Gespeichertes Todo ist abrufbar")
    func savedTodoIsRetrievable() {
        let sut = makeSUT()
        let todo = Todo(title: "Test Todo")
        sut.save(todo)
        let fetched = sut.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == todo.id)
        #expect(fetched.first?.title == "Test Todo")
    }

    @Test("Mehrere Todos werden gespeichert")
    func multipleTodosAreSaved() {
        let sut = makeSUT()
        sut.save(Todo(title: "Erster"))
        sut.save(Todo(title: "Zweiter"))
        #expect(sut.fetchAll().count == 2)
    }

    // MARK: - Aktualisieren

    @Test("Aktualisiertes Todo wird korrekt gespeichert")
    func updatedTodoIsCorrectlySaved() {
        let sut = makeSUT()
        var todo = Todo(title: "Original")
        sut.save(todo)
        todo.isCompleted = true
        sut.update(todo)
        #expect(sut.fetchAll().first?.isCompleted == true)
    }

    @Test("Update eines nicht vorhandenen Todos hat keine Auswirkung")
    func updateOfNonExistentTodoHasNoEffect() {
        let sut = makeSUT()
        let todo = Todo(title: "Nicht vorhanden")
        sut.update(todo) // sollte keinen Fehler werfen
        #expect(sut.fetchAll().isEmpty)
    }

    // MARK: - Löschen

    @Test("Gelöschtes Todo ist nicht mehr vorhanden")
    func deletedTodoIsNoLongerPresent() {
        let sut = makeSUT()
        let todo = Todo(title: "Zu löschen")
        sut.save(todo)
        sut.delete(id: todo.id)
        #expect(sut.fetchAll().isEmpty)
    }

    @Test("Löschen eines nicht vorhandenen Todos hat keine Auswirkung")
    func deletingNonExistentTodoHasNoEffect() {
        let sut = makeSUT()
        sut.save(Todo(title: "Vorhandenes Todo"))
        sut.delete(id: UUID()) // fremde ID
        #expect(sut.fetchAll().count == 1)
    }

    // MARK: - Sortierung

    @Test("Todos werden nach Erstellungsdatum sortiert zurückgegeben")
    func todosAreSortedByCreationDate() {
        let sut = makeSUT()
        let first = Todo(title: "Erster", createdAt: Date(timeIntervalSince1970: 1000))
        let second = Todo(title: "Zweiter", createdAt: Date(timeIntervalSince1970: 2000))
        sut.save(second)
        sut.save(first)
        let fetched = sut.fetchAll()
        #expect(fetched[0].title == "Erster")
        #expect(fetched[1].title == "Zweiter")
    }
}
