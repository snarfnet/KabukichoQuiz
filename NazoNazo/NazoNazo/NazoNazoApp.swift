import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

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
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        ATTrackingManager.requestTrackingAuthorization { _ in }
                    }
                }
        }
    }
}
