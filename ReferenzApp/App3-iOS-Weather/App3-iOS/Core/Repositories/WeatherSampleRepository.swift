// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Implementation of the weather repository with hard-coded sample data.
/// Provides realistic, deterministic weather data for ten cities.
final class WeatherSampleRepository: WeatherRepositoryProtocol {

    // MARK: - City List

    private let verfügbareCities: [City] = [
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000001")!, name: "Berlin",    land: "Germany",         latitude:  52.52, longitude:  13.40),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000002")!, name: "Munich",    land: "Germany",         latitude:  48.14, longitude:  11.58),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000003")!, name: "Hamburg",   land: "Germany",         latitude:  53.55, longitude:   9.99),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000004")!, name: "Vienna",    land: "Austria",         latitude:  48.21, longitude:  16.37),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000005")!, name: "Zurich",    land: "Switzerland",     latitude:  47.38, longitude:   8.54),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000006")!, name: "Paris",     land: "France",          latitude:  48.86, longitude:   2.35),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000007")!, name: "London",    land: "United Kingdom",  latitude:  51.51, longitude:  -0.13),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000008")!, name: "New York",  land: "USA",             latitude:  40.71, longitude: -74.01),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000009")!, name: "Tokyo",     land: "Japan",           latitude:  35.69, longitude: 139.69),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-00000000000A")!, name: "Sydney",    land: "Australia",       latitude: -33.87, longitude: 151.21),
    ]

    // MARK: - WeatherRepositoryProtocol

    func alleCities() -> [City] {
        verfügbareCities
    }

    func aktuellesWetter(fuer city: City) throws -> CurrentWeather {
        guard let index = verfügbareCities.firstIndex(where: { $0.id == city.id }) else {
            throw WetterFehler.stadtNichtGefunden
        }
        return erstelleWetter(fuer: city, index: index)
    }

    func wochenvorhersage(fuer city: City) throws -> WeeklyForecast {
        guard let index = verfügbareCities.firstIndex(where: { $0.id == city.id }) else {
            throw WetterFehler.stadtNichtGefunden
        }
        return erstelleVorhersage(fuer: city, basisIndex: index)
    }

    func citiesSuchen(suchbegriff: String) -> [City] {
        let bereinigt = suchbegriff.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bereinigt.isEmpty else { return verfügbareCities }
        return verfügbareCities.filter {
            $0.name.localizedCaseInsensitiveContains(bereinigt) ||
            $0.land.localizedCaseInsensitiveContains(bereinigt)
        }
    }

    // MARK: - Weather Data (deterministic sample values)

    private struct WetterVariante {
        let temperatur: Double
        let gefuehlteTemperatur: Double
        let luftfeuchtigkeit: Int
        let windgeschwindigkeit: Double
        let windrichtung: String
        let sichtweite: Double
        let uvIndex: Int
        let bedingung: WeatherCondition
    }

    private struct VorhersageVariante {
        let minTemperatur: Double
        let maxTemperatur: Double
        let bedingung: WeatherCondition
        let regenWahrscheinlichkeit: Int
        let luftfeuchtigkeit: Int
    }

    /// Ten weather variants – one per city (order matches city list).
    private let wetterVarianten: [WetterVariante] = [
        WetterVariante(temperatur: 18.0, gefuehlteTemperatur: 17.0, luftfeuchtigkeit: 60, windgeschwindigkeit: 14.0, windrichtung: "NW", sichtweite: 18.0, uvIndex: 4, bedingung: .teilbewölkt),
        WetterVariante(temperatur: 24.0, gefuehlteTemperatur: 23.0, luftfeuchtigkeit: 45, windgeschwindigkeit:  8.0, windrichtung:  "S", sichtweite: 25.0, uvIndex: 7, bedingung: .sonnig),
        WetterVariante(temperatur: 14.0, gefuehlteTemperatur: 12.0, luftfeuchtigkeit: 78, windgeschwindigkeit: 22.0, windrichtung:  "W", sichtweite: 10.0, uvIndex: 2, bedingung: .regnerisch),
        WetterVariante(temperatur: 21.0, gefuehlteTemperatur: 20.0, luftfeuchtigkeit: 55, windgeschwindigkeit: 10.0, windrichtung: "NO", sichtweite: 22.0, uvIndex: 6, bedingung: .sonnig),
        WetterVariante(temperatur: 16.0, gefuehlteTemperatur: 15.0, luftfeuchtigkeit: 65, windgeschwindigkeit: 12.0, windrichtung: "NW", sichtweite: 20.0, uvIndex: 5, bedingung: .teilbewölkt),
        WetterVariante(temperatur: 19.0, gefuehlteTemperatur: 18.0, luftfeuchtigkeit: 62, windgeschwindigkeit: 16.0, windrichtung:  "W", sichtweite: 15.0, uvIndex: 4, bedingung: .bewölkt),
        WetterVariante(temperatur: 12.0, gefuehlteTemperatur: 10.0, luftfeuchtigkeit: 82, windgeschwindigkeit: 28.0, windrichtung: "SW", sichtweite:  8.0, uvIndex: 2, bedingung: .starkRegnerisch),
        WetterVariante(temperatur: 22.0, gefuehlteTemperatur: 21.0, luftfeuchtigkeit: 50, windgeschwindigkeit: 18.0, windrichtung:  "N", sichtweite: 20.0, uvIndex: 6, bedingung: .teilbewölkt),
        WetterVariante(temperatur: 28.0, gefuehlteTemperatur: 30.0, luftfeuchtigkeit: 70, windgeschwindigkeit:  5.0, windrichtung: "SO", sichtweite: 12.0, uvIndex: 9, bedingung: .sonnig),
        WetterVariante(temperatur: 20.0, gefuehlteTemperatur: 19.0, luftfeuchtigkeit: 58, windgeschwindigkeit: 10.0, windrichtung: "NW", sichtweite: 25.0, uvIndex: 7, bedingung: .sonnig),
    ]

    /// Seven forecast variants – distributed cyclically over the week.
    private let vorhersageVarianten: [VorhersageVariante] = [
        VorhersageVariante(minTemperatur: 14.0, maxTemperatur: 22.0, bedingung: .sonnig,       regenWahrscheinlichkeit:  5, luftfeuchtigkeit: 48),
        VorhersageVariante(minTemperatur: 11.0, maxTemperatur: 18.0, bedingung: .teilbewölkt,  regenWahrscheinlichkeit: 20, luftfeuchtigkeit: 60),
        VorhersageVariante(minTemperatur:  9.0, maxTemperatur: 14.0, bedingung: .regnerisch,   regenWahrscheinlichkeit: 80, luftfeuchtigkeit: 85),
        VorhersageVariante(minTemperatur:  7.0, maxTemperatur: 13.0, bedingung: .bewölkt,      regenWahrscheinlichkeit: 45, luftfeuchtigkeit: 72),
        VorhersageVariante(minTemperatur: 15.0, maxTemperatur: 24.0, bedingung: .sonnig,       regenWahrscheinlichkeit:  5, luftfeuchtigkeit: 45),
        VorhersageVariante(minTemperatur:  4.0, maxTemperatur:  9.0, bedingung: .schneeig,     regenWahrscheinlichkeit: 70, luftfeuchtigkeit: 90),
        VorhersageVariante(minTemperatur: 12.0, maxTemperatur: 20.0, bedingung: .teilbewölkt,  regenWahrscheinlichkeit: 25, luftfeuchtigkeit: 55),
    ]

    // MARK: - Private Helpers

    private func erstelleWetter(fuer city: City, index: Int) -> CurrentWeather {
        let variante = wetterVarianten[index % wetterVarianten.count]
        let kalender = Calendar.current
        let heute = Date()
        let sonnenaufgang = kalender.date(bySettingHour: 6, minute: 30, second: 0, of: heute)!
        let sonnenuntergang = kalender.date(bySettingHour: 20, minute: 15, second: 0, of: heute)!

        return CurrentWeather(
            city: city,
            temperatur: variante.temperatur,
            gefuehlteTemperatur: variante.gefuehlteTemperatur,
            luftfeuchtigkeit: variante.luftfeuchtigkeit,
            windgeschwindigkeit: variante.windgeschwindigkeit,
            windrichtung: variante.windrichtung,
            sichtweite: variante.sichtweite,
            uvIndex: variante.uvIndex,
            bedingung: variante.bedingung,
            sonnenaufgang: sonnenaufgang,
            sonnenuntergang: sonnenuntergang
        )
    }

    private func erstelleVorhersage(fuer city: City, basisIndex: Int) -> WeeklyForecast {
        let kalender = Calendar.current
        let heute = Date()

        let tagesvorhersagen: [DailyForecast] = (0..<7).map { offset in
            let datum = kalender.date(byAdding: .day, value: offset, to: heute)!
            let varianteIndex = (basisIndex + offset) % vorhersageVarianten.count
            let variante = vorhersageVarianten[varianteIndex]
            return DailyForecast(
                datum: datum,
                minTemperatur: variante.minTemperatur,
                maxTemperatur: variante.maxTemperatur,
                bedingung: variante.bedingung,
                regenWahrscheinlichkeit: variante.regenWahrscheinlichkeit,
                luftfeuchtigkeit: variante.luftfeuchtigkeit
            )
        }

        return WeeklyForecast(city: city, vorhersagen: tagesvorhersagen)
    }
}
