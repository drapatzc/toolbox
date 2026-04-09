import Foundation

/// Ergebnis einer Validierung
enum ValidationResult {
    case valid
    case invalid([ValidationFieldError])

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var errors: [ValidationFieldError] {
        if case .invalid(let errors) = self { return errors }
        return []
    }

    /// Fehler für ein bestimmtes Feld
    func error(for field: UserField) -> String? {
        errors.first(where: { $0.field == field })?.message
    }
}
