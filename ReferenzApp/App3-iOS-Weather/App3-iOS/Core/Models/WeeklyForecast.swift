// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// 7-day weather forecast for a city.
struct WeeklyForecast: Equatable {
    /// City for which the forecast applies.
    let city: City
    /// Daily forecasts sorted ascending by date.
    let vorhersagen: [DailyForecast]

    init(city: City, vorhersagen: [DailyForecast]) {
        self.city = city
        self.vorhersagen = vorhersagen
    }
}
