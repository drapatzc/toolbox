// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// ViewModel für die 7-Tage-Wettervorhersage einer Stadt.
@Observable
final class ForecastViewModel {

    private let service: WeatherServiceProtocol

    /// Geladene Wochenvorhersage; `nil` solange noch keine Daten vorliegen.
    var wochenvorhersage: WeeklyForecast?
    /// `true` während die Vorhersage abgerufen wird.
    var isLoading: Bool = false
    /// Fehlermeldung wenn der Abruf fehlschlug; sonst `nil`.
    var fehlerMeldung: String?

    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed Properties

    /// Tagesvorhersagen der geladenen Wochenvorhersage, oder leer wenn keine Daten vorliegen.
    var vorhersagen: [DailyForecast] {
        wochenvorhersage?.vorhersagen ?? []
    }

    /// `true` wenn eine Fehlermeldung vorhanden ist.
    var hatFehler: Bool {
        fehlerMeldung != nil
    }

    // MARK: - Aktionen

    /// Lädt die 7-Tage-Vorhersage für die angegebene Stadt.
    func vorhersageLaden(fuer city: City) async {
        isLoading = true
        fehlerMeldung = nil
        do {
            wochenvorhersage = try await service.wochenvorhersage(fuer: city)
        } catch let fehler as WetterFehler {
            fehlerMeldung = fehler.localizedDescription
        } catch {
            fehlerMeldung = "Ein unbekannter Fehler ist aufgetreten."
        }
        isLoading = false
    }

    /// Setzt die aktuelle Fehlermeldung zurück.
    func fehlerZurücksetzen() {
        fehlerMeldung = nil
    }
}
