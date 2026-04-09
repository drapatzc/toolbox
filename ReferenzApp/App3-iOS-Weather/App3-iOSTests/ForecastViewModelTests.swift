// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests für `ForecastViewModel`.
/// Prüft Ladezustand, korrekte Vorhersagedaten und Fehlerbehandlung.
struct ForecastViewModelTests {

    private func makeSUT() -> (viewModel: ForecastViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        let viewModel = ForecastViewModel(service: service)
        return (viewModel, service)
    }

    private func testStadt() -> City {
        City(name: "Vorhersagestadt", land: "Testland", latitude: 48.0, longitude: 11.0)
    }

    private func testVorhersage(anzahlTage: Int = 7) -> WeeklyForecast {
        let basis = Date()
        let tage = (0..<anzahlTage).map { offset in
            DailyForecast(
                datum: basis.addingTimeInterval(Double(offset) * 86_400),
                minTemperatur: Double(offset) + 10,
                maxTemperatur: Double(offset) + 20,
                bedingung: .sonnig,
                regenWahrscheinlichkeit: 10,
                luftfeuchtigkeit: 50
            )
        }
        return WeeklyForecast(city: testStadt(), vorhersagen: tage)
    }

    // MARK: - Initialzustand

    @Test("ViewModel hat korrekten Initialzustand")
    func viewModelHatKorrektenInitialzustand() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.wochenvorhersage == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
        #expect(viewModel.vorhersagen.isEmpty)
    }

    // MARK: - vorhersageLaden (Positivpfade)

    @Test("vorhersageLaden setzt wochenvorhersage nach Erfolg")
    func vorhersageLadenSetztWochenvorhersage() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testVorhersage()
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.wochenvorhersage != nil)
    }

    @Test("vorhersageLaden: vorhersagen enthält sieben Tage")
    func vorhersageLadenVorhersagenEnthältSiebenTage() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testVorhersage()
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.vorhersagen.count == 7)
    }

    @Test("vorhersageLaden setzt isLoading nach Abschluss auf false")
    func vorhersageLadenSetztIsLoadingAufFalse() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testVorhersage()
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.isLoading == false)
    }

    @Test("vorhersageLaden setzt fehlerMeldung auf nil bei Erfolg")
    func vorhersageLadenSetzrFehlerMeldungNilBeiErfolg() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testVorhersage()
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.fehlerMeldung == nil)
    }

    @Test("vorhersagen ist leer wenn noch keine Vorhersage geladen wurde")
    func vorhersagenIstLeerOhneGeladeneDaten() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.vorhersagen.isEmpty)
    }

    @Test("vorhersageLaden übergibt die richtige Stadt an den Service")
    func vorhersageLadenÜbergibtRichtigeStadt() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testVorhersage()
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(service.wochenvorhersageAufrufe.first?.name == "Vorhersagestadt")
    }

    @Test("vorhersagen enthält korrekte Temperaturdaten")
    func vorhersagenEnthältKorrekteTemeraturdaten() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testVorhersage()
        await viewModel.vorhersageLaden(fuer: testStadt())
        let erste = viewModel.vorhersagen.first
        #expect(erste?.minTemperatur == 10.0)
        #expect(erste?.maxTemperatur == 20.0)
    }

    // MARK: - vorhersageLaden (Fehlerpfade)

    @Test("vorhersageLaden setzt fehlerMeldung bei stadtNichtGefunden")
    func vorhersageLadenSetztFehlerBeiStadtNichtGefunden() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.fehlerMeldung != nil)
    }

    @Test("vorhersageLaden setzt fehlerMeldung bei datenNichtVerfügbar")
    func vorhersageLadenSetztFehlerBeiDatenNichtVerfügbar() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .datenNichtVerfügbar
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.fehlerMeldung != nil)
    }

    @Test("hatFehler ist true wenn fehlerMeldung gesetzt ist")
    func hatFehlerIstTrueBeiGesetzterFehlerMeldung() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.hatFehler == true)
    }

    @Test("vorhersageLaden setzt isLoading nach Fehler auf false")
    func vorhersageLadenSetztIsLoadingNachFehlerAufFalse() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.isLoading == false)
    }

    @Test("vorhersagen ist leer wenn Fehler auftrat")
    func vorhersagenIstLeerBeiLadefehler() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .datenNichtVerfügbar
        await viewModel.vorhersageLaden(fuer: testStadt())
        #expect(viewModel.vorhersagen.isEmpty)
    }

    // MARK: - fehlerZurücksetzen

    @Test("fehlerZurücksetzen löscht fehlerMeldung")
    func fehlerZurücksetzenLöschtFehlerMeldung() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testStadt())
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }
}
