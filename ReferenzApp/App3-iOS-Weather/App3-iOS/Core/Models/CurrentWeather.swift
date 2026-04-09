// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Aktuelles Wetter für eine Stadt zum aktuellen Zeitpunkt.
struct CurrentWeather: Equatable {
    let city: City
    /// Temperatur in Grad Celsius.
    let temperatur: Double
    /// Gefühlte Temperatur in Grad Celsius.
    let gefuehlteTemperatur: Double
    /// Relative Luftfeuchtigkeit in Prozent (0–100).
    let luftfeuchtigkeit: Int
    /// Windgeschwindigkeit in km/h.
    let windgeschwindigkeit: Double
    /// Windrichtung als Himmelsrichtungsabkürzung (z.B. "NW").
    let windrichtung: String
    /// Sichtweite in Kilometern.
    let sichtweite: Double
    /// UV-Index (0–11+).
    let uvIndex: Int
    /// Aktuelle Wetterbedingung.
    let bedingung: WeatherCondition
    /// Uhrzeit des Sonnenaufgangs.
    let sonnenaufgang: Date
    /// Uhrzeit des Sonnenuntergangs.
    let sonnenuntergang: Date
    /// Zeitstempel der letzten Aktualisierung.
    let zuletztAktualisiert: Date

    init(
        city: City,
        temperatur: Double,
        gefuehlteTemperatur: Double,
        luftfeuchtigkeit: Int,
        windgeschwindigkeit: Double,
        windrichtung: String,
        sichtweite: Double,
        uvIndex: Int,
        bedingung: WeatherCondition,
        sonnenaufgang: Date,
        sonnenuntergang: Date,
        zuletztAktualisiert: Date = Date()
    ) {
        self.city = city
        self.temperatur = temperatur
        self.gefuehlteTemperatur = gefuehlteTemperatur
        self.luftfeuchtigkeit = luftfeuchtigkeit
        self.windgeschwindigkeit = windgeschwindigkeit
        self.windrichtung = windrichtung
        self.sichtweite = sichtweite
        self.uvIndex = uvIndex
        self.bedingung = bedingung
        self.sonnenaufgang = sonnenaufgang
        self.sonnenuntergang = sonnenuntergang
        self.zuletztAktualisiert = zuletztAktualisiert
    }

    /// Formatierte Temperaturanzeige (z.B. "22°").
    var temperaturFormatiert: String {
        String(format: "%.0f°", temperatur)
    }

    /// Formatierte gefühlte Temperatur (z.B. "20°").
    var gefuehlteTemperaturFormatiert: String {
        String(format: "%.0f°", gefuehlteTemperatur)
    }
}
