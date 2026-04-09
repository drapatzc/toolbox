// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests für `CurrentWeatherViewModel`.
/// Prüft Ladezustand, erfolgreiche Datenabruf und Fehlerbehandlung.
struct CurrentWeatherViewModelTests {

    private func makeSUT() -> (viewModel: CurrentWeatherViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        let viewModel = CurrentWeatherViewModel(service: service)
        return (viewModel, service)
    }

    private func testStadt() -> City {
        City(name: "Teststadt", land: "Testland", latitude: 48.0, longitude: 11.0)
    }

    private func testWetter() -> CurrentWeather {
        let basis = Date()
        return CurrentWeather(
            city: testStadt(),
            temperatur: 22.0,
            gefuehlteTemperatur: 21.0,
            luftfeuchtigkeit: 55,
            windgeschwindigkeit: 12.0,
            windrichtung: "NW",
            sichtweite: 18.0,
            uvIndex: 5,
            bedingung: .sonnig,
            sonnenaufgang: basis,
            sonnenuntergang: basis.addingTimeInterval(50_000)
        )
    }

    // MARK: - Initialzustand

    @Test("ViewModel hat korrekten Initialzustand")
    func viewModelHatKorrektenInitialzustand() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.aktuellesWetter == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }

    // MARK: - wetterLaden (Positivpfade)

    @Test("wetterLaden setzt aktuellesWetter nach erfolgreichem Abruf")
    func wetterLadenSetztAktuellesWetter() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWetter()
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.aktuellesWetter != nil)
        #expect(viewModel.aktuellesWetter?.temperatur == 22.0)
    }

    @Test("wetterLaden setzt isLoading nach Abschluss auf false")
    func wetterLadenSetztIsLoadingAufFalseNachAbschluss() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWetter()
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.isLoading == false)
    }

    @Test("wetterLaden setzt fehlerMeldung auf nil bei Erfolg")
    func wetterLadenSetztFehlerMeldungAufNilBeiErfolg() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWetter()
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.fehlerMeldung == nil)
    }

    @Test("wetterLaden übergibt die richtige Stadt an den Service")
    func wetterLadenÜbergibtRichtigeStadt() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWetter()
        let stadt = testStadt()
        await viewModel.wetterLaden(fuer: stadt)
        #expect(service.aktuellesWetterAufrufe.first?.name == "Teststadt")
    }

    @Test("wetterLaden setzt Wetterbedingung korrekt")
    func wetterLadenSetztWetterbedingungKorrekt() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWetter()
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.aktuellesWetter?.bedingung == .sonnig)
    }

    @Test("hatFehler ist false nach erfolgreichem Laden")
    func hatFehlerIstFalseNachErfolg() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWetter()
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.hatFehler == false)
    }

    // MARK: - wetterLaden (Fehlerpfade)

    @Test("wetterLaden setzt fehlerMeldung bei stadtNichtGefunden")
    func wetterLadenSetztFehlerBeiStadtNichtGefunden() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.fehlerMeldung != nil)
        #expect(viewModel.fehlerMeldung?.isEmpty == false)
    }

    @Test("wetterLaden setzt fehlerMeldung bei datenNichtVerfügbar")
    func wetterLadenSetztFehlerBeiDatenNichtVerfügbar() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .datenNichtVerfügbar
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.fehlerMeldung != nil)
    }

    @Test("hatFehler ist true wenn fehlerMeldung gesetzt ist")
    func hatFehlerIstTrueWennFehlerMeldungGesetzt() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.hatFehler == true)
    }

    @Test("wetterLaden setzt isLoading nach Fehler auf false")
    func wetterLadenSetztIsLoadingNachFehlerAufFalse() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.isLoading == false)
    }

    @Test("bei Fehler bleibt aktuellesWetter nil")
    func beiFehlBeibtAktuellesWetterNil() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testStadt())
        #expect(viewModel.aktuellesWetter == nil)
    }

    // MARK: - fehlerZurücksetzen

    @Test("fehlerZurücksetzen löscht die fehlerMeldung")
    func fehlerZurücksetzenLöschtFehlerMeldung() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testStadt())
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }

    @Test("fehlerZurücksetzen bei bereits nil fehlerMeldung ändert nichts")
    func fehlerZurücksetzenBeiNilIstIdempotent() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
    }
}
