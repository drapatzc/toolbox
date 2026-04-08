// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests für `CitySearchViewModel`.
/// Prüft das Laden von Städten, Suchfunktion und Stadtauswahl.
struct CitySearchViewModelTests {

    private func makeSUT() -> (viewModel: CitySearchViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        let viewModel = CitySearchViewModel(service: service)
        return (viewModel, service)
    }

    private func testStädte() -> [City] {
        [
            City(name: "Berlin",  land: "Deutschland", latitude: 52.52, longitude: 13.40),
            City(name: "München", land: "Deutschland", latitude: 48.14, longitude: 11.58),
            City(name: "Paris",   land: "Frankreich",  latitude: 48.86, longitude:  2.35),
        ]
    }

    // MARK: - Initialzustand

    @Test("ViewModel hat korrekten Initialzustand")
    func viewModelHatKorrektenInitialzustand() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.alleStaedte.isEmpty)
        #expect(viewModel.suchergebnisse.isEmpty)
        #expect(viewModel.suchbegriff.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
        #expect(viewModel.angezeigteStädte.isEmpty)
    }

    // MARK: - alleStaedteLaden

    @Test("alleStaedteLaden befüllt alleStaedte vom Service")
    func alleStaedteLadenBefülltListe() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testStädte()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.alleStaedte.count == 3)
    }

    @Test("alleStaedteLaden befüllt auch suchergebnisse initial")
    func alleStaedteLadenBefülltSuchergebnisse() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testStädte()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.suchergebnisse.count == 3)
    }

    @Test("alleStaedteLaden ruft alleCities genau einmal auf")
    func alleStaedteLadenRuftServiceEinmalAuf() async {
        let (viewModel, service) = makeSUT()
        await viewModel.alleStaedteLaden()
        #expect(service.alleCitiesAufrufe == 1)
    }

    @Test("alleStaedteLaden bei leerem Service ergibt leere Liste")
    func alleStaedteLadenBeiLeeremServiceErgibtLeersteListe() async {
        let (viewModel, _) = makeSUT()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.alleStaedte.isEmpty)
    }

    // MARK: - angezeigteStädte

    @Test("angezeigteStädte gibt alleStaedte zurück wenn kein Suchbegriff gesetzt")
    func angezeigteStädteGibtAlleStädteOhneSuchbegriff() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testStädte()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.angezeigteStädte.count == 3)
    }

    @Test("angezeigteStädte gibt suchergebnisse zurück wenn Suchbegriff gesetzt")
    func angezeigteStädteGibtSuchergebnisseMitBegriff() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testStädte()
        service.suchenResult = [testStädte()[0]] // nur Berlin
        await viewModel.alleStaedteLaden()
        viewModel.suchbegriff = "Berlin"
        await viewModel.suchen()
        #expect(viewModel.angezeigteStädte.count == 1)
        #expect(viewModel.angezeigteStädte.first?.name == "Berlin")
    }

    @Test("angezeigteStädte ist leer wenn Suche keine Treffer liefert")
    func angezeigteStädteIstLeerBeiKeinenTreffern() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = []
        viewModel.suchbegriff = "ZZZ"
        await viewModel.suchen()
        #expect(viewModel.angezeigteStädte.isEmpty)
    }

    // MARK: - suchen

    @Test("suchen aktualisiert suchergebnisse")
    func suchenAktualistertSuchergebnisse() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = [testStädte()[2]] // nur Paris
        viewModel.suchbegriff = "Paris"
        await viewModel.suchen()
        #expect(viewModel.suchergebnisse.count == 1)
        #expect(viewModel.suchergebnisse.first?.name == "Paris")
    }

    @Test("suchen setzt isLoading nach Abschluss auf false")
    func suchenSetztIsLoadingAufFalse() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = []
        await viewModel.suchen()
        #expect(viewModel.isLoading == false)
    }

    @Test("suchen übergibt aktuellen suchbegriff an Service")
    func suchenÜbergibtSuchbegriffAnService() async {
        let (viewModel, service) = makeSUT()
        viewModel.suchbegriff = "München"
        await viewModel.suchen()
        #expect(service.suchenAufrufe.last == "München")
    }

    @Test("suchen mit leerem Suchbegriff übergibt leeren String an Service")
    func suchenMitLeeremBegriffÜbergibtLeereZeichenfolge() async {
        let (viewModel, service) = makeSUT()
        viewModel.suchbegriff = ""
        await viewModel.suchen()
        #expect(service.suchenAufrufe.last == "")
    }

    @Test("suchen setzt fehlerMeldung auf nil bei Erfolg")
    func suchenSetztFehlerAufNilBeiErfolg() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = []
        await viewModel.suchen()
        #expect(viewModel.fehlerMeldung == nil)
    }

    // MARK: - fehlerZurücksetzen

    @Test("fehlerZurücksetzen entfernt die fehlerMeldung")
    func fehlerZurücksetzenEntferntFehlerMeldung() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerMeldung = "Testfehler"
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }

    @Test("fehlerZurücksetzen bei nil-Fehler ändert nichts")
    func fehlerZurücksetzenBeiNilIstSicher() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
    }

    // MARK: - hatFehler

    @Test("hatFehler ist true wenn fehlerMeldung nicht nil ist")
    func hatFehlerIstTrueBeiGesetzterMeldung() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerMeldung = "Fehler"
        #expect(viewModel.hatFehler == true)
    }

    @Test("hatFehler ist false bei nil-fehlerMeldung")
    func hatFehlerIstFalseBeiNilMeldung() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.hatFehler == false)
    }
}
