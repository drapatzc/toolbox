// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests für `WeatherService`.
/// Prüft Delegation an das Repository und Validierungslogik.
struct WeatherServiceTests {

    private func makeSUT() -> (service: WeatherService, repository: MockWeatherRepository) {
        let repository = MockWeatherRepository()
        let service = WeatherService(repository: repository)
        return (service, repository)
    }

    private func testStadt() -> City {
        City(name: "Teststadt", land: "Testland", latitude: 0, longitude: 0)
    }

    private func testWetter(fuer city: City? = nil) -> CurrentWeather {
        let stadt = city ?? City(name: "Teststadt", land: "Testland", latitude: 0, longitude: 0)
        let basis = Date()
        return CurrentWeather(
            city: stadt,
            temperatur: 20.0,
            gefuehlteTemperatur: 19.0,
            luftfeuchtigkeit: 60,
            windgeschwindigkeit: 10.0,
            windrichtung: "W",
            sichtweite: 15.0,
            uvIndex: 4,
            bedingung: .sonnig,
            sonnenaufgang: basis,
            sonnenuntergang: basis.addingTimeInterval(50_000)
        )
    }

    private func testVorhersage(fuer city: City? = nil) -> WeeklyForecast {
        let stadt = city ?? testStadt()
        let basis = Date()
        let tage = (0..<7).map { offset in
            DailyForecast(
                datum: basis.addingTimeInterval(Double(offset) * 86_400),
                minTemperatur: 10,
                maxTemperatur: 20,
                bedingung: .sonnig,
                regenWahrscheinlichkeit: 10,
                luftfeuchtigkeit: 50
            )
        }
        return WeeklyForecast(city: stadt, vorhersagen: tage)
    }

    // MARK: - alleCities

    @Test("alleCities delegiert an das Repository")
    func alleCitiesDelegiertAnRepository() {
        let (service, repository) = makeSUT()
        repository.gespeicherteCities = [testStadt()]
        let ergebnis = service.alleCities()
        #expect(ergebnis.count == 1)
        #expect(repository.alleCitiesAufrufe == 1)
    }

    @Test("alleCities gibt leere Liste zurück wenn Repository leer ist")
    func alleCitiesGibtLeerListeBeimLeerenRepository() {
        let (service, _) = makeSUT()
        #expect(service.alleCities().isEmpty)
    }

    @Test("alleCities gibt mehrere Städte korrekt zurück")
    func alleCitiesGibtMehrereStädteZurück() {
        let (service, repository) = makeSUT()
        let städte = [testStadt(), City(name: "B", land: "L", latitude: 1, longitude: 1)]
        repository.gespeicherteCities = städte
        #expect(service.alleCities().count == 2)
    }

    // MARK: - aktuellesWetter (Positivpfade)

    @Test("aktuellesWetter delegiert den Abruf ans Repository")
    func aktuellesWetterDelegiertAnRepository() async throws {
        let (service, repository) = makeSUT()
        let stadt = testStadt()
        repository.aktuellesWetterResult = testWetter(fuer: stadt)
        _ = try await service.aktuellesWetter(fuer: stadt)
        #expect(repository.aktuellesWetterAufrufe.count == 1)
        #expect(repository.aktuellesWetterAufrufe.first?.name == "Teststadt")
    }

    @Test("aktuellesWetter gibt das korrekte Wetterobjekt zurück")
    func aktuellesWetterGibtKorrektesDatenObjektZurück() async throws {
        let (service, repository) = makeSUT()
        let erwartetes = testWetter()
        repository.aktuellesWetterResult = erwartetes
        let ergebnis = try await service.aktuellesWetter(fuer: testStadt())
        #expect(ergebnis.temperatur == 20.0)
        #expect(ergebnis.bedingung == .sonnig)
    }

    // MARK: - aktuellesWetter (Fehlerpfade)

    @Test("aktuellesWetter leitet stadtNichtGefunden-Fehler weiter")
    func aktuellesWetterLeitetStadtNichtGefundenWeiter() async {
        let (service, repository) = makeSUT()
        repository.aktuellesWetterFehler = .stadtNichtGefunden
        await #expect(throws: WetterFehler.stadtNichtGefunden) {
            try await service.aktuellesWetter(fuer: testStadt())
        }
    }

    @Test("aktuellesWetter leitet datenNichtVerfügbar-Fehler weiter")
    func aktuellesWetterLeitetDatenNichtVerfügbarWeiter() async {
        let (service, repository) = makeSUT()
        repository.aktuellesWetterFehler = .datenNichtVerfügbar
        await #expect(throws: WetterFehler.datenNichtVerfügbar) {
            try await service.aktuellesWetter(fuer: testStadt())
        }
    }

    // MARK: - wochenvorhersage (Positivpfade)

    @Test("wochenvorhersage delegiert den Abruf ans Repository")
    func wochenvorhersageDelegiertAnRepository() async throws {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageResult = testVorhersage()
        _ = try await service.wochenvorhersage(fuer: testStadt())
        #expect(repository.wochenvorhersageAufrufe.count == 1)
    }

    @Test("wochenvorhersage gibt sieben Tage zurück")
    func wochenvorhersageGibtSiebenTageZurück() async throws {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageResult = testVorhersage()
        let ergebnis = try await service.wochenvorhersage(fuer: testStadt())
        #expect(ergebnis.vorhersagen.count == 7)
    }

    // MARK: - wochenvorhersage (Fehlerpfade)

    @Test("wochenvorhersage leitet stadtNichtGefunden-Fehler weiter")
    func wochenvorhersageLeitetFehlerWeiter() async {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageFehler = .stadtNichtGefunden
        await #expect(throws: WetterFehler.stadtNichtGefunden) {
            try await service.wochenvorhersage(fuer: testStadt())
        }
    }

    @Test("wochenvorhersage leitet datenNichtVerfügbar-Fehler weiter")
    func wochenvorhersageLeitetDatenFehlerWeiter() async {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageFehler = .datenNichtVerfügbar
        await #expect(throws: WetterFehler.datenNichtVerfügbar) {
            try await service.wochenvorhersage(fuer: testStadt())
        }
    }

    // MARK: - citiesSuchen

    @Test("citiesSuchen delegiert trimmierten Suchbegriff ans Repository")
    func citiesSuchenDelegiertGesäubertenBegriff() async {
        let (service, repository) = makeSUT()
        repository.gespeicherteCities = [testStadt()]
        _ = await service.citiesSuchen(suchbegriff: "  Test  ")
        #expect(repository.citiesSuchenAufrufe.first == "Test")
    }

    @Test("citiesSuchen mit leerem Begriff liefert alle Städte")
    func citiesSuchenMitLeeremBegriffLiefertAlleStädte() async {
        let (service, repository) = makeSUT()
        let städte = [testStadt(), City(name: "B", land: "L", latitude: 0, longitude: 0)]
        repository.gespeicherteCities = städte
        let ergebnis = await service.citiesSuchen(suchbegriff: "")
        #expect(ergebnis.count == 2)
    }

    @Test("citiesSuchen mit Nur-Leerzeichen trimmt zu leerem Suchbegriff")
    func citiesSuchenMitNurLeerzeichenWirdGetrimmt() async {
        let (service, repository) = makeSUT()
        _ = await service.citiesSuchen(suchbegriff: "   ")
        #expect(repository.citiesSuchenAufrufe.first == "")
    }
}
