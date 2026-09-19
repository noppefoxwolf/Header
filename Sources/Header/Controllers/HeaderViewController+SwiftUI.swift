import UIKit
public import SwiftUI

@Observable
final class LayoutAttributes {
    var safeAreaPadding: EdgeInsets = .init(.zero)
    
    func setSafeAreaInsets(_ insets: UIEdgeInsets) {
        safeAreaPadding = EdgeInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right
        )
    }
}

// workaround: safeAreaRegionsを有効にするとレイアウトでクラッシュするので、自前で送り込む
struct LayoutAttributesView<ContentView: View>: View {
    let rootView: ContentView
    
    @Environment(LayoutAttributes.self)
    var layoutAttributes: LayoutAttributes
    
    let ignoreSafeAreaPadding: Edge.Set
    
    init(rootView: ContentView, ignoreSafeAreaPadding: Edge.Set) {
        self.rootView = rootView
        self.ignoreSafeAreaPadding = ignoreSafeAreaPadding
    }
    
    // workaround: ignoreSafeArea(.bottom)を使うとimageのレイアウトがズレるのでここで無効化する
    var body: some View {
        rootView
            .safeAreaPadding(.top, ignoreSafeAreaPadding.contains(.top) ? 0 : layoutAttributes.safeAreaPadding.top)
            .safeAreaPadding(.leading, ignoreSafeAreaPadding.contains(.leading) ? 0 : layoutAttributes.safeAreaPadding.leading)
            .safeAreaPadding(.bottom, ignoreSafeAreaPadding.contains(.bottom) ? 0 : layoutAttributes.safeAreaPadding.bottom)
            .safeAreaPadding(.trailing, ignoreSafeAreaPadding.contains(.trailing) ? 0 : layoutAttributes.safeAreaPadding.trailing)
            .clipped()
    }
}

extension HeaderViewController {
    public func setHeaderBannerView<ContentView: View>(
        _ content: ContentView,
    ) {
        let hostingController = UIHostingController(
            rootView: LayoutAttributesView(rootView: content, ignoreSafeAreaPadding: .bottom).environment(layoutAttributes)
        )
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.bannerView = hostingController.view!
        hostingController.didMove(toParent: self)
    }
    
    public func setHeaderContentView<ContentView: View>(
        _ content: ContentView,
    ) {
        let hostingController = UIHostingController(
            rootView: LayoutAttributesView(rootView: content, ignoreSafeAreaPadding: [.top, .bottom]).environment(layoutAttributes)
        )
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.contentView = hostingController.view!
        hostingController.didMove(toParent: self)
    }

    public func setHeaderPaletteView<ContentView: View>(
        _ content: ContentView,
    ) {
        let hostingController = UIHostingController(
            rootView: LayoutAttributesView(rootView: content, ignoreSafeAreaPadding: [.top, .bottom]).environment(layoutAttributes)
        )
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        addChild(hostingController)
        headerView.paletteView = hostingController.view!
        hostingController.didMove(toParent: self)
    }
}
