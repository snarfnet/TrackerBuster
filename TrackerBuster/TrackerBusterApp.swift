import SwiftUI

@main
struct TrackerBusterApp: App {
    @StateObject private var scanner = BLEScanner()
    @StateObject private var adManager = AdManager.shared

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanner)
                .environmentObject(adManager)
        }
    }
}
