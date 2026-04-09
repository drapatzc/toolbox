import SwiftUI

/// Eingabeformular für neue Aufgaben.
/// Wird als Sheet präsentiert und dispatcht eine addTask-Aktion an den Store.
struct AddTaskView: View {

    let store: AppStore
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var priority: TaskPriority = .medium
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar
            Divider()
            Form {
                Section("Titel *") {
                    TextField("Aufgabentitel eingeben…", text: $title)
                        .accessibilityIdentifier("taskTitleField")
                }

                Section("Beschreibung") {
                    TextEditor(text: $taskDescription)
                        .frame(minHeight: 80)
                }

                Section("Priorität") {
                    Picker("Priorität", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { prio in
                            Text(prio.rawValue).tag(prio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let errorMessage = store.state.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(Color.red)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 420, minHeight: 360)
        .onChange(of: store.state.isAddTaskPresented) { _, isPresented in
            if !isPresented {
                dismiss()
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button("Abbrechen") {
                store.dispatch(.hideAddTask)
            }
            .keyboardShortcut(.cancelAction)

            Spacer()

            Text("Neue Aufgabe")
                .font(.headline)

            Spacer()

            Button("Hinzufügen") {
                store.dispatch(.addTask(
                    title: title,
                    description: taskDescription,
                    priority: priority
                ))
            }
            .keyboardShortcut(.defaultAction)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("addTaskConfirmButton")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
