import SwiftUI
import GoogleMobileAds

@main
struct NazoNazoApp: App {
    @StateObject private var gameManager = GameManager()

    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(gameManager)
                .preferredColorScheme(.dark)
        }
    }
}
