import SwiftUI

@main
struct TrackerBusterApp: App {
    @StateObject private var scanner = BLEScanner()

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanner)
        }
    }
}
