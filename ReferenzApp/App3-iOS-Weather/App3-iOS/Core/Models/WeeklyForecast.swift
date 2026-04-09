// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Wochenvorhersage (7 Tage) für eine Stadt.
struct WeeklyForecast: Equatable {
    /// Stadt, für die die Vorhersage gilt.
    let city: City
    /// Tagesvorhersagen, aufsteigend nach Datum sortiert.
    let vorhersagen: [DailyForecast]

    init(city: City, vorhersagen: [DailyForecast]) {
        self.city = city
        self.vorhersagen = vorhersagen
    }
}
