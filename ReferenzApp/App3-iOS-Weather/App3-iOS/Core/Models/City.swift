// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Represents a city with geographic coordinates.
struct City: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let name: String
    /// Country name (in the app's default language).
    let land: String
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        name: String,
        land: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.land = land
        self.latitude = latitude
        self.longitude = longitude
    }
}
