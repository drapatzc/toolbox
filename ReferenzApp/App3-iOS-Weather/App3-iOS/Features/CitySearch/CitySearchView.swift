// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// Main view for city search and selection.
/// Displays all available cities and enables filtered searching.
struct CitySearchView: View {

    @State var viewModel: CitySearchViewModel

    var body: some View {
        List(viewModel.angezeigteStädte) { stadt in
            NavigationLink(value: stadt) {
                StadtZeile(stadt: stadt)
            }
            .accessibilityIdentifier("stadtZeile_\(stadt.name)")
        }
        .navigationTitle(String(localized: "weather_app_title"))
        .navigationDestination(for: City.self) { stadt in
            CurrentWeatherView(
                viewModel: DependencyContainer.shared.makeCurrentWeatherViewModel(),
                forecastViewModel: DependencyContainer.shared.makeForecastViewModel(),
                stadt: stadt
            )
        }
        .searchable(text: $viewModel.suchbegriff, prompt: String(localized: "search_prompt"))
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
        .alert(String(localized: "error_title"), isPresented: Binding(
            get: { viewModel.hatFehler },
            set: { if !$0 { viewModel.fehlerZurücksetzen() } }
        )) {
            Button(String(localized: "ok")) { viewModel.fehlerZurücksetzen() }
        } message: {
            Text(viewModel.fehlerMeldung ?? "")
        }
    }
}

// MARK: - City Row

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

// MARK: - Empty State View

private struct LeerzustandAnsicht: View {
    let suchbegriff: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(suchbegriff.isEmpty
                 ? String(localized: "no_cities_available")
                 : String(format: String(localized: "no_results_for"), suchbegriff))
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
