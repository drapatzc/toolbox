// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// View for the 7-day weather forecast of a city.
struct ForecastView: View {

    @State var viewModel: ForecastViewModel
    let stadt: City

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(String(localized: "loading_forecast"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.vorhersagen.isEmpty {
                Text(String(localized: "no_forecast"))
                    .foregroundStyle(.secondary)
            } else {
                List(viewModel.vorhersagen) { vorhersage in
                    VorhersageZeile(vorhersage: vorhersage)
                }
            }
        }
        .navigationTitle(String(localized: "forecast_title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.vorhersageLaden(fuer: stadt)
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

// MARK: - Forecast Row

private struct VorhersageZeile: View {
    let vorhersage: DailyForecast

    var body: some View {
        HStack(spacing: 12) {
            Text(vorhersage.datumKurz)
                .font(.subheadline)
                .frame(width: 110, alignment: .leading)

            Image(systemName: vorhersage.bedingung.systemSymbol)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
                .frame(width: 32)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Text("\(vorhersage.regenWahrscheinlichkeit) %")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48)

            HStack(spacing: 2) {
                Text(String(format: "%.0f°", vorhersage.minTemperatur))
                    .foregroundStyle(.secondary)
                Text("/")
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f°", vorhersage.maxTemperatur))
                    .bold()
            }
            .font(.subheadline)
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
