import SwiftUI

@main
struct NazoNazoApp: App {
    @StateObject private var gameManager = GameManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(gameManager)
                .preferredColorScheme(.dark)
        }
    }
}
