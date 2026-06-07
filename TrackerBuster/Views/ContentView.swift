import SwiftUI

struct ContentView: View {
    @EnvironmentObject var scanner: BLEScanner
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ScanView()
                    .tabItem {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("スキャン")
                    }
                    .tag(0)

                DeviceListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("デバイス")
                    }
                    .tag(1)
                    .badge(scanner.suspiciousCount)

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
                    .tag(2)
            }
            .tint(Color("accentRed"))

            // Banner ad at bottom
            BannerAdView(adUnitID: AdManager.shared.bannerAdUnitID)
                .frame(height: 50)
                .padding(.bottom, 49) // Above tab bar
        }
    }
}
