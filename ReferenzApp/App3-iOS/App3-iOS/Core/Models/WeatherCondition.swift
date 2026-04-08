// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Mögliche Wetterbedingungen mit SF-Symbol und deutscher Beschreibung.
enum WeatherCondition: String, CaseIterable, Codable, Equatable {
    case sonnig
    case teilbewölkt
    case bewölkt
    case regnerisch
    case starkRegnerisch
    case gewittig
    case schneeig
    case neblig
    case windig

    /// SF-Symbol passend zur Wetterbedingung.
    var systemSymbol: String {
        switch self {
        case .sonnig:          return "sun.max.fill"
        case .teilbewölkt:     return "cloud.sun.fill"
        case .bewölkt:         return "cloud.fill"
        case .regnerisch:      return "cloud.rain.fill"
        case .starkRegnerisch: return "cloud.heavyrain.fill"
        case .gewittig:        return "cloud.bolt.rain.fill"
        case .schneeig:        return "cloud.snow.fill"
        case .neblig:          return "cloud.fog.fill"
        case .windig:          return "wind"
        }
    }

    /// Deutsche Beschreibung der Wetterbedingung.
    var beschreibung: String {
        switch self {
        case .sonnig:          return "Sonnig"
        case .teilbewölkt:     return "Teilweise bewölkt"
        case .bewölkt:         return "Bewölkt"
        case .regnerisch:      return "Regnerisch"
        case .starkRegnerisch: return "Starker Regen"
        case .gewittig:        return "Gewitter"
        case .schneeig:        return "Schnee"
        case .neblig:          return "Neblig"
        case .windig:          return "Windig"
        }
    }
}
