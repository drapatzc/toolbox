import Foundation
import Observation

/// Zentraler Store der Anwendung (Redux-Pattern).
/// Hält den aktuellen AppState und verarbeitet Aktionen über den Reducer.
/// Views beobachten den State direkt – jede Änderung löst ein Re-Render aus.
@Observable
final class AppStore {

    // MARK: - Zustand

    private(set) var state: AppState

    // MARK: - Abhängigkeiten

    private let reducer: (AppState, AppAction) -> AppState
    private let persistence: PersistenceProtocol

    // MARK: - Initialisierung

    init(
        initialState: AppState = AppState(),
        reducer: @escaping (AppState, AppAction) -> AppState = appReducer,
        persistence: PersistenceProtocol = InMemoryPersistence()
    ) {
        self.reducer = reducer
        self.persistence = persistence
        self.state = initialState
        loadFromPersistence()
    }

    // MARK: - Dispatch

    /// Verarbeitet eine Aktion: wendet den Reducer an und speichert den neuen Zustand.
    func dispatch(_ action: AppAction) {
        state = reducer(state, action)
        saveToPersistence()
    }

    // MARK: - Persistenz

    private func loadFromPersistence() {
        let loaded = persistence.loadTasks()
        state.tasks = loaded
    }

    private func saveToPersistence() {
        persistence.saveTasks(state.tasks)
    }
}
