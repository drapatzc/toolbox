// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Manages all app dependencies (Dependency Injection Container).
/// Provides pre-configured instances of services and repositories.
final class DependencyContainer {

    static let shared = DependencyContainer()

    private init() {}

    // MARK: - Repositories

    private(set) lazy var wetterRepository: WeatherRepositoryProtocol = {
        WeatherSampleRepository()
    }()

    // MARK: - Services

    private(set) lazy var wetterService: WeatherServiceProtocol = {
        WeatherService(repository: wetterRepository)
    }()

    // MARK: - ViewModels

    func makeCitySearchViewModel() -> CitySearchViewModel {
        CitySearchViewModel(service: wetterService)
    }

    func makeCurrentWeatherViewModel() -> CurrentWeatherViewModel {
        CurrentWeatherViewModel(service: wetterService)
    }

    func makeForecastViewModel() -> ForecastViewModel {
        ForecastViewModel(service: wetterService)
    }
}
