// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation
@testable import App3_iOS

/// Test-Double für `WeatherServiceProtocol`.
/// Zeichnet alle Methodenaufrufe auf und gibt konfigurierbare Testwerte zurück.
final class MockWeatherService: WeatherServiceProtocol {

    // MARK: - Konfigurierbare Rückgabewerte

    /// Städte, die `alleCities()` zurückgibt.
    var verfügbareCities: [City] = []
    /// Wenn gesetzt, wirft `aktuellesWetter(fuer:)` diesen Fehler.
    var aktuellesWetterFehler: WetterFehler?
    /// Wenn gesetzt, wirft `wochenvorhersage(fuer:)` diesen Fehler.
    var wochenvorhersageFehler: WetterFehler?
    /// Rückgabewert für `aktuellesWetter(fuer:)`.
    var aktuellesWetterResult: CurrentWeather?
    /// Rückgabewert für `wochenvorhersage(fuer:)`.
    var wochenvorhersageResult: WeeklyForecast?
    /// Rückgabewert für `citiesSuchen(suchbegriff:)`; `nil` → gibt `verfügbareCities` zurück.
    var suchenResult: [City]?

    // MARK: - Aufruf-Aufzeichnung

    /// Anzahl der `alleCities()`-Aufrufe.
    var alleCitiesAufrufe: Int = 0
    /// Städte, für die `aktuellesWetter(fuer:)` aufgerufen wurde.
    var aktuellesWetterAufrufe: [City] = []
    /// Städte, für die `wochenvorhersage(fuer:)` aufgerufen wurde.
    var wochenvorhersageAufrufe: [City] = []
    /// Suchbegriffe, mit denen `citiesSuchen(suchbegriff:)` aufgerufen wurde.
    var suchenAufrufe: [String] = []

    // MARK: - WeatherServiceProtocol

    func alleCities() -> [City] {
        alleCitiesAufrufe += 1
        return verfügbareCities
    }

    func aktuellesWetter(fuer city: City) async throws -> CurrentWeather {
        aktuellesWetterAufrufe.append(city)
        if let fehler = aktuellesWetterFehler { throw fehler }
        guard let result = aktuellesWetterResult else {
            throw WetterFehler.stadtNichtGefunden
        }
        return result
    }

    func wochenvorhersage(fuer city: City) async throws -> WeeklyForecast {
        wochenvorhersageAufrufe.append(city)
        if let fehler = wochenvorhersageFehler { throw fehler }
        guard let result = wochenvorhersageResult else {
            throw WetterFehler.datenNichtVerfügbar
        }
        return result
    }

    func citiesSuchen(suchbegriff: String) async -> [City] {
        suchenAufrufe.append(suchbegriff)
        return suchenResult ?? verfügbareCities
    }
}
