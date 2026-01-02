import SwiftUI

@main
struct MinimalSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onDisappear { exit(0) }
        }
    }
}
