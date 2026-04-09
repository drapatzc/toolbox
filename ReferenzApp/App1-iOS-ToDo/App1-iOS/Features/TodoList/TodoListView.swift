import SwiftUI

/// Hauptansicht der App: zeigt alle vorhandenen Todos als Liste.
struct TodoListView: View {

    @State private var viewModel: TodoListViewModel

    init(viewModel: TodoListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var bindable = viewModel
        NavigationStack {
            contentView
                .navigationTitle("Meine Todos")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: viewModel.showAddTodo) {
                            Label("Hinzufügen", systemImage: "plus")
                        }
                        .accessibilityIdentifier("addTodoButton")
                    }
                }
                .sheet(
                    isPresented: $bindable.isAddTodoPresented,
                    onDismiss: viewModel.loadTodos
                ) {
                    AddTodoView(viewModel: DependencyContainer.shared.makeAddTodoViewModel())
                }
                .onAppear(perform: viewModel.loadTodos)
        }
    }

    // MARK: - Unteransichten

    @ViewBuilder
    private var contentView: some View {
        if viewModel.todos.isEmpty {
            emptyStateView
        } else {
            todoList
        }
    }

    private var todoList: some View {
        List {
            ForEach(viewModel.todos) { todo in
                TodoRowView(todo: todo) {
                    viewModel.toggleCompletion(of: todo)
                }
            }
            .onDelete(perform: viewModel.deleteTodos)
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier("todoList")
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "Keine Todos vorhanden",
            systemImage: "checkmark.circle",
            description: Text("Tippe auf +, um ein neues Todo hinzuzufügen.")
        )
        .accessibilityIdentifier("emptyState")
    }
}

// MARK: - Todo-Zeile

/// Einzelne Zeile in der Todo-Liste.
private struct TodoRowView: View {

    let todo: Todo
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isCompleted ? Color.green : Color.secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? Color.secondary : Color.primary)

                Text(todo.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(todo.title)
        .accessibilityValue(todo.isCompleted ? "Erledigt" : "Offen")
    }
}
