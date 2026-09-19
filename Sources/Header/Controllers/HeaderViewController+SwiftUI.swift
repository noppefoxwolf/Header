import UIKit
public import SwiftUI

@Observable
final class LayoutAttributes {
    var safeAreaPadding: EdgeInsets = .init(.zero)
}

struct LayoutAttributesView<ContentView: View>: View {
    let rootView: ContentView
    
    @Environment(LayoutAttributes.self)
    var layoutAttributes: LayoutAttributes
    
    init(rootView: ContentView) {
        self.rootView = rootView
    }
    
    var body: some View {
        rootView
            .safeAreaPadding(layoutAttributes.safeAreaPadding)
            .background(Color.red)
    }
}

extension HeaderViewController {
    public func setHeaderBannerView<ContentView: View>(
        _ content: ContentView,
    ) {
        let hostingController = UIHostingController(rootView: LayoutAttributesView(rootView: content).environment(layoutAttributes))
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.bannerView = hostingController.view!
        hostingController.didMove(toParent: self)
    }
    
    public func setHeaderContentView<ContentView: View>(
        _ content: ContentView,
    ) {
        let hostingController = UIHostingController(rootView: LayoutAttributesView(rootView: content).environment(layoutAttributes))
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.contentView = hostingController.view!
        hostingController.didMove(toParent: self)
    }

    public func setHeaderPaletteView<ContentView: View>(
        _ content: ContentView,
    ) {
        let hostingController = UIHostingController(rootView: LayoutAttributesView(rootView: content).environment(layoutAttributes))
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.paletteView = hostingController.view!
        hostingController.didMove(toParent: self)
    }
}
