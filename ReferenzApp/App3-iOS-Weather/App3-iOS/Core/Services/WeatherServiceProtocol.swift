// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Fehlerbeschreibungen für Wetterdienst-Operationen.
enum WetterFehler: Error, LocalizedError, Equatable {
    /// Die angegebene Stadt ist im Datensatz nicht vorhanden.
    case stadtNichtGefunden
    /// Wetterdaten können nicht abgerufen werden.
    case datenNichtVerfügbar

    var errorDescription: String? {
        switch self {
        case .stadtNichtGefunden:
            return "Die gewählte Stadt konnte nicht gefunden werden."
        case .datenNichtVerfügbar:
            return "Die Wetterdaten sind derzeit nicht verfügbar."
        }
    }
}

/// Schnittstelle für den Wetter-Service.
/// Stellt Wetterdaten asynchron bereit und abstrahiert die Datenquelle.
protocol WeatherServiceProtocol {
    /// Gibt alle verfügbaren Städte synchron zurück.
    func alleCities() -> [City]

    /// Ruft das aktuelle Wetter für eine Stadt asynchron ab.
    /// - Throws: `WetterFehler` bei Fehlern.
    func aktuellesWetter(fuer city: City) async throws -> CurrentWeather

    /// Ruft die 7-Tage-Vorhersage für eine Stadt asynchron ab.
    /// - Throws: `WetterFehler` bei Fehlern.
    func wochenvorhersage(fuer city: City) async throws -> WeeklyForecast

    /// Sucht Städte nach Name oder Land.
    /// Gibt bei leerem Suchbegriff alle Städte zurück.
    func citiesSuchen(suchbegriff: String) async -> [City]
}
