// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// Einstiegspunkt der App3-iOS Wetter-App.
/// Richtet den Dependency-Container ein und startet die Hauptansicht.
@main
struct App3_iOSApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CitySearchView(viewModel: DependencyContainer.shared.makeCitySearchViewModel())
            }
        }
    }
}
