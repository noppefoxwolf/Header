import UIKit

@MainActor
final class ScrollViewPanGestureRelay {
    private weak var panGestureProxy: UIPanGestureRecognizer?

    func updatePanGestureProxy(for scrollView: UIScrollView, in containerView: UIView) {
        // Allow dragging from the header by attaching the scroll view's pan gesture to the container.
        if let panGestureProxy, panGestureProxy !== scrollView.panGestureRecognizer {
            panGestureProxy.view?.removeGestureRecognizer(panGestureProxy)
        }
        let panGestureRecognizer = scrollView.panGestureRecognizer
        if panGestureRecognizer.view !== containerView {
            containerView.addGestureRecognizer(panGestureRecognizer)
        }
        panGestureProxy = panGestureRecognizer
    }
}
