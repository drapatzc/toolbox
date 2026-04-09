// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation
@testable import App3_iOS

/// Test-Double für `WeatherRepositoryProtocol`.
/// Zeichnet alle Methodenaufrufe auf und gibt konfigurierbare Testwerte zurück.
final class MockWeatherRepository: WeatherRepositoryProtocol {

    // MARK: - Konfigurierbare Rückgabewerte

    /// Städte, die `alleCities()` zurückgibt.
    var gespeicherteCities: [City] = []
    /// Wenn gesetzt, wirft `aktuellesWetter(fuer:)` diesen Fehler.
    var aktuellesWetterFehler: WetterFehler?
    /// Wenn gesetzt, wirft `wochenvorhersage(fuer:)` diesen Fehler.
    var wochenvorhersageFehler: WetterFehler?
    /// Rückgabewert für `aktuellesWetter(fuer:)`.
    var aktuellesWetterResult: CurrentWeather?
    /// Rückgabewert für `wochenvorhersage(fuer:)`.
    var wochenvorhersageResult: WeeklyForecast?

    // MARK: - Aufruf-Aufzeichnung

    /// Anzahl der `alleCities()`-Aufrufe.
    var alleCitiesAufrufe: Int = 0
    /// Städte, für die `aktuellesWetter(fuer:)` aufgerufen wurde.
    var aktuellesWetterAufrufe: [City] = []
    /// Städte, für die `wochenvorhersage(fuer:)` aufgerufen wurde.
    var wochenvorhersageAufrufe: [City] = []
    /// Suchbegriffe, mit denen `citiesSuchen(suchbegriff:)` aufgerufen wurde.
    var citiesSuchenAufrufe: [String] = []

    // MARK: - WeatherRepositoryProtocol

    func alleCities() -> [City] {
        alleCitiesAufrufe += 1
        return gespeicherteCities
    }

    func aktuellesWetter(fuer city: City) throws -> CurrentWeather {
        aktuellesWetterAufrufe.append(city)
        if let fehler = aktuellesWetterFehler { throw fehler }
        guard let result = aktuellesWetterResult else {
            throw WetterFehler.stadtNichtGefunden
        }
        return result
    }

    func wochenvorhersage(fuer city: City) throws -> WeeklyForecast {
        wochenvorhersageAufrufe.append(city)
        if let fehler = wochenvorhersageFehler { throw fehler }
        guard let result = wochenvorhersageResult else {
            throw WetterFehler.datenNichtVerfügbar
        }
        return result
    }

    func citiesSuchen(suchbegriff: String) -> [City] {
        citiesSuchenAufrufe.append(suchbegriff)
        guard !suchbegriff.isEmpty else { return gespeicherteCities }
        return gespeicherteCities.filter {
            $0.name.localizedCaseInsensitiveContains(suchbegriff) ||
            $0.land.localizedCaseInsensitiveContains(suchbegriff)
        }
    }
}
