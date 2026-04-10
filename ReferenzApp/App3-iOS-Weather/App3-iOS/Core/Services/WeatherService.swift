// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Concrete implementation of the weather service.
/// Delegates data access to the repository and adds validation logic.
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
