// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Wettervorhersage für einen einzelnen Tag.
struct DailyForecast: Identifiable, Equatable {
    let id: UUID
    /// Datum des Vorhersagetags.
    let datum: Date
    /// Minimale Tagestemperatur in Grad Celsius.
    let minTemperatur: Double
    /// Maximale Tagestemperatur in Grad Celsius.
    let maxTemperatur: Double
    /// Wetterbedingung des Tages.
    let bedingung: WeatherCondition
    /// Regenwahrscheinlichkeit in Prozent (0–100).
    let regenWahrscheinlichkeit: Int
    /// Relative Luftfeuchtigkeit in Prozent (0–100).
    let luftfeuchtigkeit: Int

    init(
        id: UUID = UUID(),
        datum: Date,
        minTemperatur: Double,
        maxTemperatur: Double,
        bedingung: WeatherCondition,
        regenWahrscheinlichkeit: Int,
        luftfeuchtigkeit: Int
    ) {
        self.id = id
        self.datum = datum
        self.minTemperatur = minTemperatur
        self.maxTemperatur = maxTemperatur
        self.bedingung = bedingung
        self.regenWahrscheinlichkeit = regenWahrscheinlichkeit
        self.luftfeuchtigkeit = luftfeuchtigkeit
    }

    /// Vollständiger Tagesname auf Deutsch (z.B. "Montag").
    var tagesname: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: datum)
    }

    /// Kurze Datumsdarstellung (z.B. "Mo, 10. Apr").
    var datumKurz: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, d. MMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: datum)
    }
}
