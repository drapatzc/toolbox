// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// Hauptansicht zur Stadtsuche und -auswahl.
/// Zeigt alle verfügbaren Städte und ermöglicht die gefilterte Suche.
struct CitySearchView: View {

    @State var viewModel: CitySearchViewModel

    var body: some View {
        List(viewModel.angezeigteStädte) { stadt in
            NavigationLink(value: stadt) {
                StadtZeile(stadt: stadt)
            }
            .accessibilityIdentifier("stadtZeile_\(stadt.name)")
        }
        .navigationTitle("Wetter-App")
        .navigationDestination(for: City.self) { stadt in
            CurrentWeatherView(
                viewModel: DependencyContainer.shared.makeCurrentWeatherViewModel(),
                forecastViewModel: DependencyContainer.shared.makeForecastViewModel(),
                stadt: stadt
            )
        }
        .searchable(text: $viewModel.suchbegriff, prompt: "Stadt oder Land suchen")
        .onChange(of: viewModel.suchbegriff) { _, _ in
            Task { await viewModel.suchen() }
        }
        .task {
            await viewModel.alleStaedteLaden()
        }
        .overlay {
            if viewModel.angezeigteStädte.isEmpty && !viewModel.isLoading {
                LeerzustandAnsicht(suchbegriff: viewModel.suchbegriff)
            }
        }
        .alert("Fehler", isPresented: Binding(
            get: { viewModel.hatFehler },
            set: { if !$0 { viewModel.fehlerZurücksetzen() } }
        )) {
            Button("OK") { viewModel.fehlerZurücksetzen() }
        } message: {
            Text(viewModel.fehlerMeldung ?? "")
        }
    }
}

// MARK: - StadtZeile

private struct StadtZeile: View {
    let stadt: City

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(stadt.name)
                .font(.headline)
            Text(stadt.land)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - LeerzustandAnsicht

private struct LeerzustandAnsicht: View {
    let suchbegriff: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(suchbegriff.isEmpty
                 ? "Keine Städte verfügbar"
                 : "Keine Treffer für \"\(suchbegriff)\"")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
