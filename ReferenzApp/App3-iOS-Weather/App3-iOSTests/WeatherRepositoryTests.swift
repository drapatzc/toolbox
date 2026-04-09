// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests für `WeatherSampleRepository`.
/// Prüft sowohl die Positivpfade (korrekte Rückgaben) als auch Fehlerfälle.
struct WeatherRepositoryTests {

    private func makeSUT() -> WeatherSampleRepository {
        WeatherSampleRepository()
    }

    /// Erstellt eine bekannte Berliner Teststadt (ID aus dem Repository).
    private func berlin() -> City {
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000001")!,
             name: "Berlin", land: "Deutschland", latitude: 52.52, longitude: 13.40)
    }

    /// Erstellt eine unbekannte Stadt, die nicht im Repository vorkommt.
    private func unbekannteStadt() -> City {
        City(name: "Nirgendwo", land: "Unbekannt", latitude: 0, longitude: 0)
    }

    // MARK: - alleCities

    @Test("alleCities gibt genau zehn Städte zurück")
    func alleCitiesGibtZehnStädteZurück() {
        let sut = makeSUT()
        #expect(sut.alleCities().count == 10)
    }

    @Test("alleCities enthält Berlin")
    func alleCitiesEnthältBerlin() {
        let sut = makeSUT()
        #expect(sut.alleCities().contains { $0.name == "Berlin" })
    }

    @Test("alleCities enthält München")
    func alleCitiesEnthältMünchen() {
        let sut = makeSUT()
        #expect(sut.alleCities().contains { $0.name == "München" })
    }

    @Test("alleCities enthält keine Duplikate (eindeutige IDs)")
    func alleCitiesEnthältKeineIdDuplikate() {
        let sut = makeSUT()
        let ids = sut.alleCities().map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("alleCities enthält keine leeren Namen")
    func alleCitiesEnthältKeineLeereNamen() {
        let sut = makeSUT()
        #expect(sut.alleCities().allSatisfy { !$0.name.isEmpty })
    }

    // MARK: - aktuellesWetter (Positivpfade)

    @Test("aktuellesWetter gibt Wetter für Berlin zurück")
    func aktuellesWetterGibtWetterFürBerlinZurück() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.city.name == "Berlin")
    }

    @Test("aktuellesWetter: Temperatur liegt in plausiblem Bereich (-30 bis 50 °C)")
    func aktuellesWetterTemperaturInPlausiblemBereich() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.temperatur >= -30 && wetter.temperatur <= 50)
    }

    @Test("aktuellesWetter: gefühlte Temperatur liegt in plausiblem Bereich")
    func aktuellesWetterGefühlteTemperaturInPlausiblemBereich() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.gefuehlteTemperatur >= -40 && wetter.gefuehlteTemperatur <= 55)
    }

    @Test("aktuellesWetter: Luftfeuchtigkeit liegt zwischen 0 und 100 Prozent")
    func aktuellesWetterLuftfeuchtigkeitInGültigemBereich() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.luftfeuchtigkeit >= 0 && wetter.luftfeuchtigkeit <= 100)
    }

    @Test("aktuellesWetter: Windgeschwindigkeit ist nicht negativ")
    func aktuellesWetterWindgeschwindigkeitNichtNegativ() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.windgeschwindigkeit >= 0)
    }

    @Test("aktuellesWetter: Sichtweite ist positiv")
    func aktuellesWetterSichtweitePositiv() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.sichtweite > 0)
    }

    @Test("aktuellesWetter: UV-Index liegt zwischen 0 und 11")
    func aktuellesWetterUvIndexInGültigemBereich() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.uvIndex >= 0 && wetter.uvIndex <= 11)
    }

    @Test("aktuellesWetter: Windrichtung ist nicht leer")
    func aktuellesWetterWindrichtungNichtLeer() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(!wetter.windrichtung.isEmpty)
    }

    @Test("aktuellesWetter: Sonnenaufgang liegt vor Sonnenuntergang")
    func aktuellesWetterSonnenaufgangVorSonnenuntergang() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.sonnenaufgang < wetter.sonnenuntergang)
    }

    @Test("aktuellesWetter liefert deterministisch gleiches Ergebnis für dieselbe Stadt")
    func aktuellesWetterIstDeterministisch() throws {
        let sut = makeSUT()
        let ersteAbfrage = try sut.aktuellesWetter(fuer: berlin())
        let zweiteAbfrage = try sut.aktuellesWetter(fuer: berlin())
        #expect(ersteAbfrage.temperatur == zweiteAbfrage.temperatur)
        #expect(ersteAbfrage.bedingung == zweiteAbfrage.bedingung)
    }

    // MARK: - aktuellesWetter (Fehlerpfade)

    @Test("aktuellesWetter wirft stadtNichtGefunden für unbekannte Stadt")
    func aktuellesWetterWirftFehlerFürUnbekannteStadt() {
        let sut = makeSUT()
        #expect(throws: WetterFehler.stadtNichtGefunden) {
            try sut.aktuellesWetter(fuer: unbekannteStadt())
        }
    }

    @Test("aktuellesWetter wirft Fehler wenn Stadt-ID nicht existiert")
    func aktuellesWetterWirftFehlerBeiUnbekannterID() {
        let sut = makeSUT()
        let fremdStadt = City(id: UUID(), name: "Berlin", land: "Deutschland", latitude: 52.52, longitude: 13.40)
        #expect(throws: WetterFehler.stadtNichtGefunden) {
            try sut.aktuellesWetter(fuer: fremdStadt)
        }
    }

    // MARK: - wochenvorhersage (Positivpfade)

    @Test("wochenvorhersage gibt sieben Tagesvorhersagen zurück")
    func wochenvorhersageGibtSiebenTageZurück() throws {
        let sut = makeSUT()
        let vorhersage = try sut.wochenvorhersage(fuer: berlin())
        #expect(vorhersage.vorhersagen.count == 7)
    }

    @Test("wochenvorhersage: Minimaltemperatur <= Maximaltemperatur an jedem Tag")
    func wochenvorhersageMinTempKleinerGleichMaxTemp() throws {
        let sut = makeSUT()
        let vorhersage = try sut.wochenvorhersage(fuer: berlin())
        #expect(vorhersage.vorhersagen.allSatisfy { $0.minTemperatur <= $0.maxTemperatur })
    }

    @Test("wochenvorhersage: Regenwahrscheinlichkeit zwischen 0 und 100")
    func wochenvorhersageRegenWahrscheinlichkeitInGültigemBereich() throws {
        let sut = makeSUT()
        let vorhersage = try sut.wochenvorhersage(fuer: berlin())
        #expect(vorhersage.vorhersagen.allSatisfy {
            $0.regenWahrscheinlichkeit >= 0 && $0.regenWahrscheinlichkeit <= 100
        })
    }

    @Test("wochenvorhersage: Luftfeuchtigkeit aller Tage zwischen 0 und 100")
    func wochenvorhersageLuftfeuchtigkeitAllerTageGültig() throws {
        let sut = makeSUT()
        let vorhersage = try sut.wochenvorhersage(fuer: berlin())
        #expect(vorhersage.vorhersagen.allSatisfy {
            $0.luftfeuchtigkeit >= 0 && $0.luftfeuchtigkeit <= 100
        })
    }

    @Test("wochenvorhersage: Daten gehören zur angefragten Stadt")
    func wochenvorhersageGehörtZurAngefragtenStadt() throws {
        let sut = makeSUT()
        let vorhersage = try sut.wochenvorhersage(fuer: berlin())
        #expect(vorhersage.city.name == "Berlin")
    }

    // MARK: - wochenvorhersage (Fehlerpfade)

    @Test("wochenvorhersage wirft stadtNichtGefunden für unbekannte Stadt")
    func wochenvorhersageWirftFehlerFürUnbekannteStadt() {
        let sut = makeSUT()
        #expect(throws: WetterFehler.stadtNichtGefunden) {
            try sut.wochenvorhersage(fuer: unbekannteStadt())
        }
    }

    // MARK: - citiesSuchen (Positivpfade)

    @Test("citiesSuchen mit leerem Begriff gibt alle Städte zurück")
    func citiesSuchenMitLeeremBegriffGibtAlleStädte() {
        let sut = makeSUT()
        #expect(sut.citiesSuchen(suchbegriff: "").count == 10)
    }

    @Test("citiesSuchen findet Berlin nach Name")
    func citiesSuchenFindetBerlinNachName() {
        let sut = makeSUT()
        let ergebnis = sut.citiesSuchen(suchbegriff: "Berlin")
        #expect(ergebnis.count == 1)
        #expect(ergebnis.first?.name == "Berlin")
    }

    @Test("citiesSuchen findet deutsche Städte nach Landname")
    func citiesSuchenFindetStädteNachLand() {
        let sut = makeSUT()
        let ergebnis = sut.citiesSuchen(suchbegriff: "Deutschland")
        #expect(ergebnis.count == 3) // Berlin, München, Hamburg
    }

    @Test("citiesSuchen ist Groß-/Kleinschreibungs-unabhängig")
    func citiesSuchenIstCaseInsensitiv() {
        let sut = makeSUT()
        let groß = sut.citiesSuchen(suchbegriff: "BERLIN")
        let klein = sut.citiesSuchen(suchbegriff: "berlin")
        #expect(groß.count == klein.count)
        #expect(groß.first?.name == klein.first?.name)
    }

    @Test("citiesSuchen mit Nur-Leerzeichen-Begriff gibt alle Städte zurück")
    func citiesSuchenMitNurLeerzeichenGibtAlleStädte() {
        let sut = makeSUT()
        #expect(sut.citiesSuchen(suchbegriff: "   ").count == 10)
    }

    // MARK: - citiesSuchen (Fehlerpfade)

    @Test("citiesSuchen gibt leere Liste für nicht existierende Stadt zurück")
    func citiesSuchenGibtLeereListeFürNichtExistierendeStadt() {
        let sut = makeSUT()
        let ergebnis = sut.citiesSuchen(suchbegriff: "ZZZNichtVorhandenXXX")
        #expect(ergebnis.isEmpty)
    }
}
