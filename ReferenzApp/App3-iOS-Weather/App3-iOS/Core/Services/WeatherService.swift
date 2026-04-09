// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Konkrete Implementierung des Wetter-Services.
/// Delegiert den Datenzugriff an das Repository und ergänzt Validierungslogik.
final class WeatherService: WeatherServiceProtocol {

    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - WeatherServiceProtocol

    func alleCities() -> [City] {
        repository.alleCities()
    }

    func aktuellesWetter(fuer city: City) async throws -> CurrentWeather {
        try repository.aktuellesWetter(fuer: city)
    }

    func wochenvorhersage(fuer city: City) async throws -> WeeklyForecast {
        try repository.wochenvorhersage(fuer: city)
    }

    func citiesSuchen(suchbegriff: String) async -> [City] {
        let bereinigt = suchbegriff.trimmingCharacters(in: .whitespacesAndNewlines)
        return repository.citiesSuchen(suchbegriff: bereinigt)
    }
}
