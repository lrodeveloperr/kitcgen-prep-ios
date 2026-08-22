import SwiftUI

@main
struct KitchenPrepBoardApp: App {
    @StateObject private var app = AppModel()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .preferredColorScheme(app.preferredColorScheme)
        }
    }
}
