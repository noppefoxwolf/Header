import UIKit
import SwiftUI
import Header
import Pager

@MainActor
enum HeaderDemoFactory {
    static func make(
        rootViewController: UIViewController & HeaderViewControllerDelegate,
        palette: Palette = .automatic,
        tallContent: Bool = false
    ) -> HeaderViewController {
        let headerViewController = HeaderViewController(rootViewController: rootViewController)
        headerViewController.delegate = rootViewController
        
        let headerBannerHostingController = makeHostingController(rootView: HeaderBannerView())
        addChild(headerBannerHostingController, to: headerViewController) {
            if #available(iOS 26.0, *) {
                let headerBackgroundView = HeaderBackgroundView()
                let headerBannerView = headerBannerHostingController.view!
                headerBackgroundView.contentView = headerBannerView
                headerViewController.headerView.bannerView = headerBackgroundView
            } else {
                headerViewController.headerView.bannerView = headerBannerHostingController.view
            }
        }
        
        headerViewController.setHeaderContentView(HeaderContentView(isTall: tallContent))
        
        configurePalette(
            for: rootViewController,
            in: headerViewController,
            palette: palette
        )
        
        return headerViewController
    }

    enum Palette {
        case none
        case automatic
        case view(UIView)
        case viewController(UIViewController)
    }

    private static func makeHostingController<Content: View>(
        rootView: Content
    ) -> UIHostingController<Content> {
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.safeAreaRegions = []
        hostingController.sizingOptions = .intrinsicContentSize
        hostingController.view.backgroundColor = .clear
        return hostingController
    }

    private static func addChild(
        _ child: UIViewController,
        to parent: UIViewController,
        attach: () -> Void
    ) {
        parent.addChild(child)
        attach()
        child.didMove(toParent: parent)
    }

    private static func configurePalette(
        for rootViewController: UIViewController,
        in headerViewController: HeaderViewController,
        palette: Palette
    ) {
        let resolvedPalette: ResolvedPalette
        switch palette {
        case .automatic:
            if let vc = rootViewController as? PagerPageViewController {
                resolvedPalette = .view(PageTabBar(state: vc.state))
            } else {
                let onSelectPage: ((Int) -> Void)?
                if let pageViewController = rootViewController as? PageViewController {
                    onSelectPage = { [weak pageViewController] index in
                        pageViewController?.selectPage(at: index)
                    }
                } else {
                    onSelectPage = nil
                }
                let paletteHostingController = makeHostingController(
                    rootView: HeaderPaletteView(onSelectPage: onSelectPage)
                )
                resolvedPalette = .viewController(paletteHostingController)
            }
        case .none:
            resolvedPalette = .none
        case .view(let paletteView):
            resolvedPalette = .view(paletteView)
        case .viewController(let paletteViewController):
            resolvedPalette = .viewController(paletteViewController)
        }

        switch resolvedPalette {
        case .none:
            break
        case .view(let paletteView):
            headerViewController.headerView.paletteView = paletteView
        case .viewController(let paletteViewController):
            addChild(paletteViewController, to: headerViewController) {
                headerViewController.headerView.paletteView = paletteViewController.view
            }
        }
    }

    private enum ResolvedPalette {
        case none
        case view(UIView)
        case viewController(UIViewController)
    }
}
