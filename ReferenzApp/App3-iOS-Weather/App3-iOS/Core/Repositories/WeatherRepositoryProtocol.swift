// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Schnittstelle für den Wetter-Datenzugriff.
/// Implementierungen können echte Netzwerkquellen oder Testdaten bereitstellen.
protocol WeatherRepositoryProtocol {
    /// Gibt alle verfügbaren Städte zurück.
    func alleCities() -> [City]

    /// Lädt das aktuelle Wetter für eine bekannte Stadt.
    /// - Parameter city: Die gewünschte Stadt.
    /// - Throws: `WetterFehler.stadtNichtGefunden` wenn die Stadt unbekannt ist.
    func aktuellesWetter(fuer city: City) throws -> CurrentWeather

    /// Lädt die 7-Tage-Vorhersage für eine bekannte Stadt.
    /// - Parameter city: Die gewünschte Stadt.
    /// - Throws: `WetterFehler.stadtNichtGefunden` wenn die Stadt unbekannt ist.
    func wochenvorhersage(fuer city: City) throws -> WeeklyForecast

    /// Sucht Städte anhand eines Suchbegriffs (Name oder Land).
    /// - Parameter suchbegriff: Suchtext; leerer String gibt alle Städte zurück.
    func citiesSuchen(suchbegriff: String) -> [City]
}
