import SwiftUI

/// Eingabeformular zum Erstellen eines neuen Todos.
struct AddTodoView: View {

    @State private var viewModel: AddTodoViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AddTodoViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Titel") {
                    TextField("Todo eingeben…", text: $viewModel.title)
                        .accessibilityIdentifier("todoTitleField")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(Color.red)
                    }
                }
            }
            .navigationTitle("Neues Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.saveTodo()
                    }
                    .disabled(!viewModel.isTitleValid)
                    .accessibilityIdentifier("saveTodoButton")
                }
            }
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }
}
