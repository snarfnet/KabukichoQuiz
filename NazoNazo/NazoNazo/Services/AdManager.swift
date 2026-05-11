import SwiftUI
import GoogleMobileAds

class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    static let bannerAdUnitID = "ca-app-pub-9404799280370656/3314931225"
    static let interstitialAdUnitID = "ca-app-pub-9404799280370656/6583258245"

    @Published var interstitialAd: InterstitialAd?
    private var showCount = 0

    override init() {
        super.init()
        loadInterstitial()
    }

    func loadInterstitial() {
        InterstitialAd.load(with: Self.interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            if let error = error {
                print("Interstitial load error: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
        }
    }

    func showInterstitialIfReady(from rootViewController: UIViewController) {
        showCount += 1
        guard showCount % 3 == 0, let ad = interstitialAd else { return }
        ad.present(from: rootViewController)
        loadInterstitial()
    }
}

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdManager.bannerAdUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootVC
        }
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
