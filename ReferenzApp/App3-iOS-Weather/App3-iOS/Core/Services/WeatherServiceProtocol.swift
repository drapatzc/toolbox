// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Error descriptions for weather service operations.
enum WetterFehler: Error, LocalizedError, Equatable {
    /// The specified city is not present in the data set.
    case stadtNichtGefunden
    /// Weather data cannot be retrieved.
    case datenNichtVerfügbar

    var errorDescription: String? {
        switch self {
        case .stadtNichtGefunden:
            return String(localized: "error_city_not_found")
        case .datenNichtVerfügbar:
            return String(localized: "error_data_unavailable")
        }
    }
}

/// Interface for the weather service.
/// Provides weather data asynchronously and abstracts the data source.
protocol WeatherServiceProtocol {
    /// Returns all available cities synchronously.
    func alleCities() -> [City]

    /// Retrieves the current weather for a city asynchronously.
    /// - Throws: `WetterFehler` on failure.
    func aktuellesWetter(fuer city: City) async throws -> CurrentWeather

    /// Retrieves the 7-day forecast for a city asynchronously.
    /// - Throws: `WetterFehler` on failure.
    func wochenvorhersage(fuer city: City) async throws -> WeeklyForecast

    /// Searches cities by name or country.
    /// Returns all cities when the search term is empty.
    func citiesSuchen(suchbegriff: String) async -> [City]
}
