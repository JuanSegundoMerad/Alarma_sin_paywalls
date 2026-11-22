import SwiftUI

@main
struct AlarmaMyApp: App {
    @State private var coordinator = Phase1AlarmCoordinator.shared

    var body: some Scene {
        WindowGroup {
            Phase1HomeView(coordinator: coordinator)
                .preferredColorScheme(.dark)
        }
    }
}
