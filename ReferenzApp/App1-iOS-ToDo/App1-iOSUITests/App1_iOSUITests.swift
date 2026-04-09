import XCTest

/// UI-Tests für die App1-iOS Todo-App.
/// Prüft grundlegende Benutzerinteraktionen und Navigation.
final class App1_iOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App-Start

    func testAppStartsSuccessfully() {
        XCTAssert(app.state == .runningForeground, "Die App sollte im Vordergrund laufen.")
    }

    func testListViewIsVisible() {
        XCTAssertTrue(
            app.navigationBars["Meine Todos"].exists,
            "Die Navigationsleiste mit 'Meine Todos' sollte sichtbar sein."
        )
    }

    // MARK: - Navigation

    func testAddButtonNavigatesToAddTodoView() {
        let addButton = app.buttons["addTodoButton"]
        XCTAssertTrue(addButton.exists, "Der Hinzufügen-Button sollte vorhanden sein.")
        addButton.tap()
        XCTAssertTrue(
            app.navigationBars["Neues Todo"].waitForExistence(timeout: 2.0),
            "Die Eingabeansicht sollte erscheinen."
        )
    }

    func testCancelDismissesAddTodoView() {
        app.buttons["addTodoButton"].tap()
        XCTAssertTrue(app.navigationBars["Neues Todo"].waitForExistence(timeout: 2.0))
        app.buttons["Abbrechen"].tap()
        XCTAssertTrue(
            app.navigationBars["Meine Todos"].waitForExistence(timeout: 2.0),
            "Die Liste sollte nach dem Abbrechen wieder sichtbar sein."
        )
    }

    // MARK: - Todo anlegen

    func testNewTodoCanBeCreated() {
        app.buttons["addTodoButton"].tap()

        let titleField = app.textFields["todoTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2.0), "Das Titelfeld sollte erscheinen.")
        titleField.tap()
        titleField.typeText("Mein erstes UI-Test-Todo")

        let saveButton = app.buttons["saveTodoButton"]
        XCTAssertTrue(saveButton.isEnabled, "Der Speichern-Button sollte aktiv sein.")
        saveButton.tap()

        XCTAssertTrue(
            app.staticTexts["Mein erstes UI-Test-Todo"].waitForExistence(timeout: 2.0),
            "Das neue Todo sollte in der Liste erscheinen."
        )
    }

    func testSaveButtonIsDisabledForEmptyTitle() {
        app.buttons["addTodoButton"].tap()
        let saveButton = app.buttons["saveTodoButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2.0))
        XCTAssertFalse(
            saveButton.isEnabled,
            "Der Speichern-Button sollte bei leerem Titel deaktiviert sein."
        )
    }

    func testMultipleTodosCanBeCreated() {
        let titles = ["Einkaufen", "Sport", "Lesen"]
        for title in titles {
            app.buttons["addTodoButton"].tap()
            let titleField = app.textFields["todoTitleField"]
            XCTAssertTrue(titleField.waitForExistence(timeout: 2.0))
            titleField.tap()
            titleField.typeText(title)
            app.buttons["saveTodoButton"].tap()
            XCTAssertTrue(app.navigationBars["Meine Todos"].waitForExistence(timeout: 2.0))
        }
        for title in titles {
            XCTAssertTrue(app.staticTexts[title].exists, "'\(title)' sollte in der Liste erscheinen.")
        }
    }
}
