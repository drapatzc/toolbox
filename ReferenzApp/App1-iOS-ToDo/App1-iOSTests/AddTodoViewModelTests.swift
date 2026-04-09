import Testing
import Foundation
@testable import App1_iOS

/// Tests für das AddTodoViewModel.
struct AddTodoViewModelTests {

    private func makeSUT() -> (viewModel: AddTodoViewModel, service: MockTodoService) {
        let service = MockTodoService()
        let viewModel = AddTodoViewModel(service: service)
        return (viewModel, service)
    }

    // MARK: - Validierung

    @Test("Leerer Titel ist ungültig")
    func emptyTitleIsInvalid() {
        let (viewModel, _) = makeSUT()
        viewModel.title = ""
        #expect(viewModel.isTitleValid == false)
    }

    @Test("Leerzeichen-Titel ist ungültig")
    func whitespaceOnlyTitleIsInvalid() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "   "
        #expect(viewModel.isTitleValid == false)
    }

    @Test("Nicht-leerer Titel ist gültig")
    func nonEmptyTitleIsValid() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "Mein Todo"
        #expect(viewModel.isTitleValid == true)
    }

    // MARK: - Speichern (Erfolgspfad)

    @Test("Erfolgreiches Speichern setzt isSaved auf true")
    func successfulSaveSetsIsSavedToTrue() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "Gültiges Todo"
        viewModel.saveTodo()
        #expect(viewModel.isSaved == true)
    }

    @Test("Erfolgreiches Speichern setzt keine Fehlermeldung")
    func successfulSaveDoesNotSetErrorMessage() {
        let (viewModel, _) = makeSUT()
        viewModel.title = "Gültiges Todo"
        viewModel.saveTodo()
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Erfolgreiches Speichern delegiert an Service")
    func successfulSaveDelegatesToService() {
        let (viewModel, service) = makeSUT()
        viewModel.title = "Service-Test"
        viewModel.saveTodo()
        #expect(service.createCallCount == 1)
    }

    // MARK: - Speichern (Fehlerpfad)

    @Test("Speichern bei Fehler setzt Fehlermeldung")
    func savingWithErrorSetsErrorMessage() {
        let (viewModel, service) = makeSUT()
        service.createShouldThrow = true
        viewModel.title = "Valider Titel"
        viewModel.saveTodo()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isSaved == false)
    }
}
