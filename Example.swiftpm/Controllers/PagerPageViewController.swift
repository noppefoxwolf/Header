import Pager
import SwiftUI
import UIKit
import Header

final class PagerPageViewController: Pager.PageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        if #available(iOS 26.0, *) {
            collectionView.topEdgeEffect.isHidden = true
        }
    }
}

extension PagerPageViewController: Pager.PageViewControllerDelegate {
    func willTransition(to pendingViewControllers: [UIViewController]) {
        print("willTransition")
        pendingViewControllers.forEach {
            $0.loadViewIfNeeded()
        }
        let scrollView = pendingViewControllers.compactMap({ $0.contentScrollView(for: .top) }).first
        scrollView?.willMove(to: headerViewController!)
    }
    
    func didFinishTransition(_ pageViewController: Pager.PageViewController) {
        print("didFinishTransition")
        let scrollView = contentScrollView(for: .top)
        scrollView?.didMove(to: headerViewController!)
    }
}

extension PagerPageViewController: HeaderViewControllerDelegate {
    func headerViewController(_ headerViewController: HeaderViewController, scrollStateDidChange state: HeaderViewController.ScrollState) {
        switch state {
        case .shrinking(true), .pinned:
            title = "Pager.PageViewController"
        default:
            title = nil
        }
    }
}

extension PagerPageViewController {
    static func makeDefaultPages() -> [Page] {
        [
            Page(
                id: "1",
                title: "Posts",
                viewControllerProvider: { _ in
                    PlainViewController()
                }),
            Page(
                id: "2",
                title: "Media",
                viewControllerProvider: { _ in
                    CollectionViewController(title: "CollectionView:2", cellCount: 3, applyDelay: 3)
                }),
            Page(
                id: "3",
                title: "Likes",
                viewControllerProvider: { _ in
                    CollectionViewController(title: "CollectionView:3", cellCount: 100)
                }),
        ]
    }
}
