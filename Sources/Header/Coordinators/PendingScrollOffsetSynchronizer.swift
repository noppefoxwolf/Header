import UIKit
import Combine

@MainActor
final class PendingScrollOffsetSynchronizer {
    private enum PendingOffsetSynchronization {
        case matchCurrent(offsetY: CGFloat)
        case clamp(minimumOffsetY: CGFloat)

        init(currentOffsetY: CGFloat, minimumHeaderHeight: CGFloat, safeAreaTop: CGFloat) {
            let minimumOffsetY = -(minimumHeaderHeight + safeAreaTop)
            if currentOffsetY < minimumOffsetY {
                self = .matchCurrent(offsetY: currentOffsetY)
            } else {
                self = .clamp(minimumOffsetY: minimumOffsetY)
            }
        }
    }

    private var pendingContentOffsetCancellables = Set<AnyCancellable>()
    private var pendingContentOffsetFixCancellables = Set<AnyCancellable>()
    private var isSynchronizingPendingOffsets = false

    private let activeScrollView: () -> UIScrollView?
    private let minimumHeaderHeight: () -> CGFloat
    private let safeAreaTop: () -> CGFloat

    init(
        activeScrollView: @escaping () -> UIScrollView?,
        minimumHeaderHeight: @escaping () -> CGFloat,
        safeAreaTop: @escaping () -> CGFloat
    ) {
        self.activeScrollView = activeScrollView
        self.minimumHeaderHeight = minimumHeaderHeight
        self.safeAreaTop = safeAreaTop
    }

    func synchronizePendingScrollOffsets(_ pendingScrollViews: [UIScrollView]) {
        guard let activeScrollView = activeScrollView() else { return }
        isSynchronizingPendingOffsets = true
        defer { isSynchronizingPendingOffsets = false }
        resetPendingContentOffsetFixes()

        let synchronization = PendingOffsetSynchronization(
            currentOffsetY: activeScrollView.contentOffset.y,
            minimumHeaderHeight: minimumHeaderHeight(),
            safeAreaTop: safeAreaTop()
        )

        for pendingScrollView in pendingScrollViews {
            let targetOffsetY: CGFloat?
            switch synchronization {
            case .matchCurrent(let offsetY):
                // If the current page is stretched beyond the header's minimum,
                // make pending pages match the same stretched position.
                targetOffsetY = offsetY
            case .clamp(let minimumOffsetY):
                // Otherwise, clamp pending pages to the minimum header position.
                targetOffsetY = pendingScrollView.contentOffset.y < minimumOffsetY ? minimumOffsetY : nil
            }
            guard let targetOffsetY else { continue }
            let targetContentOffset = CGPoint(x: pendingScrollView.contentOffset.x, y: targetOffsetY)
            pendingContentOffsetFixCancellables.insert(
                pendingScrollView.fixContentOffset(targetContentOffset)
            )
        }
    }

    func startObservingPendingScrollOffsets(_ pendingScrollViews: [UIScrollView]) {
        stopObservingPendingScrollOffsets()
        for pendingScrollView in pendingScrollViews {
            pendingScrollView.publisher(for: \.contentOffset)
                .removeDuplicates()
                .sink { [weak self, weak pendingScrollView] contentOffset in
                    guard let self = self, pendingScrollView != nil else { return }
                    guard !self.isSynchronizingPendingOffsets else { return }
                    self.synchronizePendingScrollOffsets(pendingScrollViews)
                }
                .store(in: &pendingContentOffsetCancellables)
        }
    }

    func stopObservingPendingScrollOffsets() {
        pendingContentOffsetCancellables.forEach { $0.cancel() }
        pendingContentOffsetCancellables.removeAll(keepingCapacity: true)
        resetPendingContentOffsetFixes()
    }

    private func resetPendingContentOffsetFixes() {
        pendingContentOffsetFixCancellables.forEach { $0.cancel() }
        pendingContentOffsetFixCancellables.removeAll(keepingCapacity: true)
    }
}
