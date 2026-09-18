import SwiftUI

@main
struct BiometricsLabApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WelcomeView()
            }
            .tint(.orange)
        }
    }
}
