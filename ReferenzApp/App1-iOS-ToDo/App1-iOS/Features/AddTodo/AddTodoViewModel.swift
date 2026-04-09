import Foundation
import Observation

/// ViewModel für das Anlegen eines neuen Todos.
/// Kapselt Validierung und Delegation an den Service.
@Observable
final class AddTodoViewModel {

    // MARK: - Zustand

    var title: String = ""
    private(set) var errorMessage: String?
    private(set) var isSaved: Bool = false

    // MARK: - Abhängigkeiten

    private let service: TodoServiceProtocol

    init(service: TodoServiceProtocol) {
        self.service = service
    }

    // MARK: - Validierung

    var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Aktionen

    func saveTodo() {
        do {
            _ = try service.createTodo(title: title)
            isSaved = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
