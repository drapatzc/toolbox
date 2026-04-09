import XCTest

/// UI-Tests für die App2-MacOS Aufgabenverwaltung.
/// Prüft grundlegende Benutzerinteraktionen und Navigation.
final class App2_MacOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        // Warten bis das Hauptfenster und die Toolbar vollständig geladen sind
        _ = app.windows.firstMatch.waitForExistence(timeout: 5.0)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App-Start

    func testAppStartsSuccessfully() {
        XCTAssert(app.state == .runningForeground, "Die App sollte im Vordergrund laufen.")
    }

    func testTaskListIsVisible() {
        let taskList = app.outlines["taskList"].firstMatch
        XCTAssertTrue(
            taskList.exists || app.tables["taskList"].exists,
            "Die Aufgabenliste sollte in der Seitenleiste sichtbar sein."
        )
    }

    func testWindowTitleIsVisible() {
        XCTAssertTrue(
            app.windows.firstMatch.exists,
            "Das Hauptfenster sollte vorhanden sein."
        )
    }

    // MARK: - Neue Aufgabe

    func testAddTaskButtonIsVisible() {
        let addButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Der Hinzufügen-Button sollte sichtbar sein.")
    }

    func testNewTaskCanBeCreated() {
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()

        let titleField = app.textFields["taskTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3.0), "Das Titelfeld sollte erscheinen.")
        titleField.click()
        titleField.typeText("Meine Test-Aufgabe")

        let confirmButton = app.buttons["addTaskConfirmButton"]
        XCTAssertTrue(confirmButton.isEnabled, "Der Hinzufügen-Button sollte aktiv sein.")
        confirmButton.click()

        XCTAssertTrue(
            app.staticTexts["Meine Test-Aufgabe"].waitForExistence(timeout: 2.0),
            "Die neue Aufgabe sollte in der Liste erscheinen."
        )
    }

    func testAddTaskConfirmButtonIsDisabledWithEmptyTitle() {
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()
        let confirmButton = app.buttons["addTaskConfirmButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3.0))
        XCTAssertFalse(
            confirmButton.isEnabled,
            "Der Bestätigen-Button sollte bei leerem Titel deaktiviert sein."
        )
    }

    func testCancelDismissesAddTaskSheet() {
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()
        XCTAssertTrue(app.textFields["taskTitleField"].waitForExistence(timeout: 3.0))
        app.buttons["Abbrechen"].click()
        XCTAssertFalse(
            app.textFields["taskTitleField"].waitForExistence(timeout: 1.0),
            "Das Eingabeformular sollte nach Abbrechen verschwinden."
        )
    }

    // MARK: - Aufgabe auswählen

    func testSelectingTaskShowsDetailView() {
        // Aufgabe anlegen
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()
        let titleField = app.textFields["taskTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3.0))
        titleField.click()
        titleField.typeText("Detail-Test-Aufgabe")
        app.buttons["addTaskConfirmButton"].click()

        // Aufgabe auswählen
        XCTAssertTrue(app.staticTexts["Detail-Test-Aufgabe"].waitForExistence(timeout: 2.0))
        app.staticTexts["Detail-Test-Aufgabe"].click()

        // Detailbereich prüfen
        XCTAssertTrue(
            app.buttons["deleteTaskButton"].waitForExistence(timeout: 2.0),
            "Der Löschen-Button sollte im Detailbereich sichtbar sein."
        )
    }
}
