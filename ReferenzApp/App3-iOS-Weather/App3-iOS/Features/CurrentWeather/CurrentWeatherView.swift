// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// Ansicht für das aktuelle Wetter einer Stadt.
/// Zeigt Temperatur, Wetterbedingung und Detailinformationen.
struct CurrentWeatherView: View {

    @State var viewModel: CurrentWeatherViewModel
    @State var forecastViewModel: ForecastViewModel
    let stadt: City

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Wetter wird geladen…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let wetter = viewModel.aktuellesWetter {
                WetterInhalt(wetter: wetter)
            } else {
                Text("Keine Wetterdaten verfügbar.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(stadt.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ForecastView(viewModel: forecastViewModel, stadt: stadt)
                } label: {
                    Label("7-Tage-Vorhersage", systemImage: "calendar")
                }
                .accessibilityIdentifier("vorhersageButton")
            }
        }
        .task {
            await viewModel.wetterLaden(fuer: stadt)
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

// MARK: - WetterInhalt

private struct WetterInhalt: View {
    let wetter: CurrentWeather

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HauptanzeigeSektionView(wetter: wetter)
                DetailKartenSektionView(wetter: wetter)
            }
            .padding(.bottom, 32)
        }
    }
}

// MARK: - HauptanzeigeSektionView

private struct HauptanzeigeSektionView: View {
    let wetter: CurrentWeather

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: wetter.bedingung.systemSymbol)
                .font(.system(size: 80))
                .symbolRenderingMode(.multicolor)
                .accessibilityIdentifier("wetterSymbol")

            Text(wetter.temperaturFormatiert)
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .accessibilityIdentifier("temperaturLabel")

            Text(wetter.bedingung.beschreibung)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Gefühlt \(wetter.gefuehlteTemperaturFormatiert)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

// MARK: - DetailKartenSektionView

private struct DetailKartenSektionView: View {
    let wetter: CurrentWeather

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            WetterDetailKarte(
                symbol: "humidity.fill",
                titel: "Luftfeuchtigkeit",
                wert: "\(wetter.luftfeuchtigkeit) %"
            )
            WetterDetailKarte(
                symbol: "wind",
                titel: "Wind",
                wert: "\(String(format: "%.0f", wetter.windgeschwindigkeit)) km/h \(wetter.windrichtung)"
            )
            WetterDetailKarte(
                symbol: "eye.fill",
                titel: "Sichtweite",
                wert: "\(String(format: "%.0f", wetter.sichtweite)) km"
            )
            WetterDetailKarte(
                symbol: "sun.max.fill",
                titel: "UV-Index",
                wert: "\(wetter.uvIndex)"
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - WetterDetailKarte

private struct WetterDetailKarte: View {
    let symbol: String
    let titel: String
    let wert: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(titel)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(wert)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
