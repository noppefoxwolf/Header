import UIKit
import Combine

@MainActor
final class AdditionalSafeAreaInsetsCoordinator {
    private var contentSizeCancellables: [ObjectIdentifier: AnyCancellable] = [:]
    private var contentHeights: [ObjectIdentifier: CGFloat] = [:]
    private var currentBottomInsetValue: CGFloat = 0
    private let rootViewController: UIViewController
    private let inset: () -> CGFloat
    private let headerViewHeight: () -> CGFloat
    private let availableHeight: () -> CGFloat

    var currentBottomInset: CGFloat {
        currentBottomInsetValue
    }

    init(
        rootViewController: UIViewController,
        inset: @escaping () -> CGFloat,
        headerViewHeight: @escaping () -> CGFloat,
        availableHeight: @escaping () -> CGFloat
    ) {
        self.rootViewController = rootViewController
        self.inset = inset
        self.headerViewHeight = headerViewHeight
        self.availableHeight = availableHeight
    }

    @MainActor deinit {
        contentSizeCancellables.values.forEach { $0.cancel() }
    }

    func updateObservedScrollViews(_ scrollViews: [UIScrollView]) {
        let identifiers = Set(scrollViews.map { ObjectIdentifier($0) })
        let removedIds = contentSizeCancellables.keys.filter { !identifiers.contains($0) }
        for id in removedIds {
            contentSizeCancellables[id]?.cancel()
            contentSizeCancellables.removeValue(forKey: id)
            contentHeights.removeValue(forKey: id)
        }

        for scrollView in scrollViews {
            let id = ObjectIdentifier(scrollView)
            if contentSizeCancellables[id] == nil {
                startObserving(scrollView)
            } else {
                contentHeights[id] = scrollView.contentSize.height
            }
        }

        applyInsets()
        applyMaxInset()
    }

    func refresh() {
        applyInsets()
        applyMaxInset()
    }

    private func startObserving(_ scrollView: UIScrollView) {
        let id = ObjectIdentifier(scrollView)
        contentHeights[id] = scrollView.contentSize.height
        contentSizeCancellables[id] = scrollView.publisher(for: \.contentSize)
            .removeDuplicates()
            .sink { [weak self, weak scrollView] contentSize in
                guard let self = self, scrollView != nil else { return }
                self.contentHeights[id] = contentSize.height
                self.applyMaxInset()
            }
    }

    private func applyMaxInset() {
        let targetHeight = max(0, availableHeight())
        let maxInset = contentHeights.values
            .map { max(0, targetHeight - $0) }
            .max() ?? 0
        guard maxInset != currentBottomInsetValue else { return }
        currentBottomInsetValue = maxInset
        applyInsets()
    }

    private func applyInsets() {
        rootViewController.additionalSafeAreaInsets.top = headerViewHeight() + inset()
        rootViewController.additionalSafeAreaInsets.bottom = currentBottomInsetValue
    }
}
