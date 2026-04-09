// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// ViewModel für die Stadtsuche und -auswahl.
@Observable
final class CitySearchViewModel {

    private let service: WeatherServiceProtocol

    /// Alle bekannten Städte (initial geladen).
    var alleStaedte: [City] = []
    /// Suchergebnisse nach aktuellem Suchbegriff.
    var suchergebnisse: [City] = []
    /// Aktueller Suchtext.
    var suchbegriff: String = ""
    /// Gibt an, ob gerade eine Suchanfrage läuft.
    var isLoading: Bool = false
    /// Fehlermeldung bei Problemen.
    var fehlerMeldung: String?

    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed Properties

    /// Zeigt Suchergebnisse wenn ein Suchbegriff gesetzt ist, sonst alle Städte.
    var angezeigteStädte: [City] {
        suchbegriff.isEmpty ? alleStaedte : suchergebnisse
    }

    /// `true` wenn eine Fehlermeldung vorhanden ist.
    var hatFehler: Bool {
        fehlerMeldung != nil
    }

    // MARK: - Aktionen

    /// Lädt alle verfügbaren Städte vom Service.
    func alleStaedteLaden() async {
        alleStaedte = service.alleCities()
        suchergebnisse = alleStaedte
    }

    /// Führt eine Stadtsuche mit dem aktuellen `suchbegriff` durch.
    func suchen() async {
        isLoading = true
        fehlerMeldung = nil
        suchergebnisse = await service.citiesSuchen(suchbegriff: suchbegriff)
        isLoading = false
    }

    /// Setzt die aktuelle Fehlermeldung zurück.
    func fehlerZurücksetzen() {
        fehlerMeldung = nil
    }
}
