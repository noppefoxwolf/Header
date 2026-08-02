import UIKit
public import SwiftUI

extension HeaderViewController {
    public func setHeaderBannerView<ContentView: View>(_ content: ContentView) {
        let hostingController = UIHostingController(rootView: content)
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.bannerView = hostingController.view!
        hostingController.didMove(toParent: self)
    }
    
    public func setHeaderContentView<ContentView: View>(_ content: ContentView) {
        let hostingController = UIHostingController(rootView: content)
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.contentView = hostingController.view!
        hostingController.didMove(toParent: self)
    }

    public func setHeaderPaletteView<ContentView: View>(_ content: ContentView) {
        let hostingController = UIHostingController(rootView: content)
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.paletteView = hostingController.view!
        hostingController.didMove(toParent: self)
    }
}
