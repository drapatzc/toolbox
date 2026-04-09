// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Repräsentiert eine Stadt mit geografischen Koordinaten.
struct City: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let name: String
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
