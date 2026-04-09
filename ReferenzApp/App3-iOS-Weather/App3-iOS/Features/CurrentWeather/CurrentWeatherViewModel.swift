// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// ViewModel für die Anzeige des aktuellen Wetters einer Stadt.
@Observable
final class CurrentWeatherViewModel {

    private let service: WeatherServiceProtocol

    /// Geladene Wetterdaten; `nil` solange noch keine Daten vorliegen.
    var aktuellesWetter: CurrentWeather?
    /// `true` während die Wetterdaten abgerufen werden.
    var isLoading: Bool = false
    /// Fehlermeldung wenn der Abruf fehlschlug; sonst `nil`.
    var fehlerMeldung: String?

    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed Properties

    /// `true` wenn eine Fehlermeldung vorhanden ist.
    var hatFehler: Bool {
        fehlerMeldung != nil
    }

    // MARK: - Aktionen

    /// Lädt das aktuelle Wetter für die angegebene Stadt.
    func wetterLaden(fuer city: City) async {
        isLoading = true
        fehlerMeldung = nil
        do {
            aktuellesWetter = try await service.aktuellesWetter(fuer: city)
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
