import XCTest

final class UserDetailUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
        // Testbenutzer anlegen, damit Detailansicht erreichbar ist
        createTestUser(firstName: "Detail", lastName: "TestUser")
        openFirstUserDetail()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Setup-Hilfsmethoden

    private func createTestUser(firstName: String, lastName: String) {
        let newUserBtn = app.buttons["btn_newUser"]
        guard newUserBtn.waitForExistence(timeout: 3) else { return }
        newUserBtn.tap()
        guard app.buttons["btn_cancel"].waitForExistence(timeout: 3) else { return }

        fillFormField("tf_firstName", text: firstName)
        fillFormField("tf_lastName", text: lastName)
        fillFormField("tf_street", text: "Detailstraße")
        fillFormField("tf_houseNumber", text: "7")
        app.swipeUp()
        fillFormField("tf_postalCode", text: "10115")
        fillFormField("tf_city", text: "Berlin")
        app.buttons["btn_save"].tap()
        _ = app.buttons["btn_newUser"].waitForExistence(timeout: 5)
    }

    private func openFirstUserDetail() {
        let list = app.collectionViews["userList"]
        guard list.waitForExistence(timeout: 3) else { return }
        let firstCell = list.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 3) else { return }
        firstCell.tap()
        // Auf iPad: Detail erscheint direkt; auf iPhone: Navigation
        _ = app.buttons["btn_edit"].waitForExistence(timeout: 3)
    }

    private func fillFormField(_ identifier: String, text: String) {
        let field = app.textFields[identifier]
        if field.waitForExistence(timeout: 2) && field.isHittable {
            field.tap()
            field.clearText()
            field.typeText(text)
        }
    }

    // MARK: - Detailansicht Struktur

    func test_detailView_showsEditButton() {
        XCTAssertTrue(app.buttons["btn_edit"].waitForExistence(timeout: 3))
    }

    func test_detailView_showsDeleteButton() {
        XCTAssertTrue(app.buttons["btn_deleteUser"].waitForExistence(timeout: 3))
    }

    func test_detailView_showsUserName() {
        // Der vollständige Name sollte irgendwo im Navigationsbereich oder Inhalt erscheinen
        let nameText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'TestUser'")).firstMatch
        XCTAssertTrue(nameText.waitForExistence(timeout: 3))
    }

    func test_detailView_showsAddress() {
        let streetText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Detailstraße'")).firstMatch
        XCTAssertTrue(streetText.waitForExistence(timeout: 3))
    }

    // MARK: - Bearbeiten

    func test_editButton_opensEditForm() {
        app.buttons["btn_edit"].tap()
        XCTAssertTrue(app.buttons["btn_cancel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["btn_save"].exists)
    }

    func test_editForm_hasPrefilled_firstName() {
        app.buttons["btn_edit"].tap()
        let firstNameField = app.textFields["tf_firstName"]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 3))
        let value = firstNameField.value as? String ?? ""
        XCTAssertEqual(value, "Detail")
    }

    func test_editForm_hasPrefilled_lastName() {
        app.buttons["btn_edit"].tap()
        let lastNameField = app.textFields["tf_lastName"]
        XCTAssertTrue(lastNameField.waitForExistence(timeout: 3))
        let value = lastNameField.value as? String ?? ""
        XCTAssertEqual(value, "TestUser")
    }

    func test_editForm_cancel_returnsToDetail() {
        app.buttons["btn_edit"].tap()
        XCTAssertTrue(app.buttons["btn_cancel"].waitForExistence(timeout: 3))
        app.buttons["btn_cancel"].tap()
        XCTAssertTrue(app.buttons["btn_edit"].waitForExistence(timeout: 3))
    }

    func test_editUser_updatesName() {
        app.buttons["btn_edit"].tap()
        XCTAssertTrue(app.buttons["btn_cancel"].waitForExistence(timeout: 3))

        let firstNameField = app.textFields["tf_firstName"]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 2))
        firstNameField.tap()
        firstNameField.clearText()
        firstNameField.typeText("Geändert")

        app.buttons["btn_save"].tap()

        // Detailansicht zeigt den neuen Namen
        let updatedName = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Geändert'")
        ).firstMatch
        XCTAssertTrue(updatedName.waitForExistence(timeout: 5))
    }

    // MARK: - Löschen

    func test_deleteButton_showsConfirmationDialog() {
        app.buttons["btn_deleteUser"].tap()
        // Bestätigungsdialog erscheint
        let deleteBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Delete' OR label CONTAINS[c] 'Löschen'")
        ).firstMatch
        XCTAssertTrue(deleteBtn.waitForExistence(timeout: 3))
    }

    func test_cancelDelete_keepsUser() {
        app.buttons["btn_deleteUser"].tap()

        let cancelBtn = app.buttons.matching(
            NSPredicate(format: "label == 'Cancel' OR label == 'Abbrechen'")
        ).firstMatch
        XCTAssertTrue(cancelBtn.waitForExistence(timeout: 3))
        cancelBtn.tap()

        // Detailansicht noch offen
        XCTAssertTrue(app.buttons["btn_edit"].waitForExistence(timeout: 3))
    }

    func test_confirmDelete_removesUser() {
        app.buttons["btn_deleteUser"].tap()

        let confirmDeleteBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Delete' OR label CONTAINS[c] 'Löschen'")
        ).firstMatch
        XCTAssertTrue(confirmDeleteBtn.waitForExistence(timeout: 3))
        confirmDeleteBtn.tap()

        // App kehrt zur Liste zurück — New-User-Button wieder sichtbar
        XCTAssertTrue(app.buttons["btn_newUser"].waitForExistence(timeout: 5))
    }
}

