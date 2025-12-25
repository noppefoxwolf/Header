import UIKit
import Combine

@MainActor
final class ActiveScrollViewCoordinator {
    private(set) weak var activeScrollView: UIScrollView?
    private var activeScrollViewOffsetCancellable: AnyCancellable?
    private let onContentOffsetChange: (UIScrollView) -> Void
    private let onDidActivateScrollView: (UIScrollView) -> Void

    init(
        onContentOffsetChange: @escaping (UIScrollView) -> Void,
        onDidActivateScrollView: @escaping (UIScrollView) -> Void = { _ in }
    ) {
        self.onContentOffsetChange = onContentOffsetChange
        self.onDidActivateScrollView = onDidActivateScrollView
    }

    @MainActor deinit {
        activeScrollViewOffsetCancellable?.cancel()
    }

    func startObserving(_ scrollView: UIScrollView) {
        guard activeScrollView !== scrollView else { return }
        
        // Disabled navigationBar background auto-luminance
        if #available(iOS 26.0, *) {
            scrollView.topEdgeEffect.isHidden = true
        }
        activeScrollView = scrollView

        // Cancel previous subscription to avoid multiple sinks.
        activeScrollViewOffsetCancellable?.cancel()
        activeScrollViewOffsetCancellable = scrollView.publisher(for: \.contentOffset)
            .sink { [weak self, weak scrollView] _ in
                guard let self = self, let scrollView = scrollView else { return }
                self.onContentOffsetChange(scrollView)
            }

        onDidActivateScrollView(scrollView)
    }
}
