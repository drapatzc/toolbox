// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// View for the current weather of a city.
/// Displays temperature, weather condition, and detailed information.
struct CurrentWeatherView: View {

    @State var viewModel: CurrentWeatherViewModel
    @State var forecastViewModel: ForecastViewModel
    let stadt: City

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(String(localized: "loading_weather"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let wetter = viewModel.aktuellesWetter {
                WetterInhalt(wetter: wetter)
            } else {
                Text(String(localized: "no_weather_data"))
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
                    Label(String(localized: "forecast_button_label"), systemImage: "calendar")
                }
                .accessibilityIdentifier("vorhersageButton")
            }
        }
        .task {
            await viewModel.wetterLaden(fuer: stadt)
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

// MARK: - Weather Content

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

// MARK: - Main Display Section

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

            Text(String(format: String(localized: "feels_like"), wetter.gefuehlteTemperaturFormatiert))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

// MARK: - Detail Cards Section

private struct DetailKartenSektionView: View {
    let wetter: CurrentWeather

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            WetterDetailKarte(
                symbol: "humidity.fill",
                titel: String(localized: "humidity"),
                wert: "\(wetter.luftfeuchtigkeit) %"
            )
            WetterDetailKarte(
                symbol: "wind",
                titel: String(localized: "wind"),
                wert: "\(String(format: "%.0f", wetter.windgeschwindigkeit)) km/h \(wetter.windrichtung)"
            )
            WetterDetailKarte(
                symbol: "eye.fill",
                titel: String(localized: "visibility"),
                wert: "\(String(format: "%.0f", wetter.sichtweite)) km"
            )
            WetterDetailKarte(
                symbol: "sun.max.fill",
                titel: String(localized: "uv_index"),
                wert: "\(wetter.uvIndex)"
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Weather Detail Card

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
