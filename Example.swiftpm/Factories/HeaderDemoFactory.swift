import UIKit
import SwiftUI
import Header

@MainActor
enum HeaderDemoFactory {
    static func make(
        rootViewController: UIViewController & HeaderViewControllerDelegate,
        palette: Palette = .automatic
    ) -> HeaderViewController {
        let headerViewController = HeaderViewController(rootViewController: rootViewController)
        headerViewController.delegate = rootViewController
        let headerBackgroundHostingController = makeHostingController(rootView: HeaderBackgroundView())
        addChild(headerBackgroundHostingController, to: headerViewController) {
            headerViewController.headerView.backgroundView = headerBackgroundHostingController.view
        }
        
        let headerContentHostingController = makeHostingController(rootView: HeaderContentView())
        addChild(headerContentHostingController, to: headerViewController) {
            headerViewController.headerView.contentView = headerContentHostingController.view
        }
        
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
                resolvedPalette = .view(vc.pageTabBar)
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
                    rootView: PaletteView(onSelectPage: onSelectPage)
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
