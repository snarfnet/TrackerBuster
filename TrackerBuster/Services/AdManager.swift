import SwiftUI
import GoogleMobileAds

class AdManager: ObservableObject {
    static let shared = AdManager()

    // AdMob App ID is set in Info.plist
    let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174" // Test ID - replace with real

    func configure() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }
        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
