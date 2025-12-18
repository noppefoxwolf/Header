import UIKit

@MainActor
final class HeaderViewLayoutCoordinator {
    struct LayoutState {
        let state: HeaderScrollState
        let headerEffectiveHeight: CGFloat
        let maxHeaderShift: CGFloat
    }

    enum HeaderScrollState {
        case stretched(adjustedTopOffset: CGFloat)
        case shrinking(adjustedTopOffset: CGFloat, isContentViewOverlappingSafeArea: Bool)
        case pinned
    }

    private let headerTopConstraint: NSLayoutConstraint
    private let headerBottomConstraint: NSLayoutConstraint

    init(
        headerTopConstraint: NSLayoutConstraint,
        headerBottomConstraint: NSLayoutConstraint,
    ) {
        self.headerTopConstraint = headerTopConstraint
        self.headerBottomConstraint = headerBottomConstraint
    }

    func calculateLayoutState(
        for scrollView: UIScrollView,
        inset: CGFloat,
        minimumHeaderHeight: CGFloat,
        headerHeight: CGFloat,
        safeAreaTop: CGFloat,
        contentViewTopOffset: CGFloat
    ) -> LayoutState {
        let headerBaseHeight = headerHeight + safeAreaTop + inset
        let headerEffectiveHeight = max(headerBaseHeight, safeAreaTop + minimumHeaderHeight)
        let adjustedTopOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let maxHeaderShift = max(0, headerEffectiveHeight - (safeAreaTop + minimumHeaderHeight))
        let state = HeaderScrollState(
            adjustedTopOffset: adjustedTopOffset,
            maxHeaderShift: maxHeaderShift,
            safeAreaTop: safeAreaTop,
            contentViewTopOffset: contentViewTopOffset
        )
        return LayoutState(
            state: state,
            headerEffectiveHeight: headerEffectiveHeight,
            maxHeaderShift: maxHeaderShift
        )
    }

    func applyLayout(
        state: HeaderScrollState,
        headerEffectiveHeight: CGFloat,
        maxHeaderShift: CGFloat
    ) {
        switch state {
        case .stretched(let adjustedTopOffset):
            let headerTopConstant: CGFloat = 0
            let headerBottomConstant = headerEffectiveHeight - adjustedTopOffset
            updateHeaderConstants(top: headerTopConstant, bottom: headerBottomConstant)
        case .shrinking(let adjustedTopOffset, _):
            let headerShift = min(adjustedTopOffset, maxHeaderShift)
            let headerTopConstant = -headerShift
            let headerBottomConstant = headerTopConstant + headerEffectiveHeight
            updateHeaderConstants(top: headerTopConstant, bottom: headerBottomConstant)
        case .pinned:
            let headerTopConstant = -maxHeaderShift
            let headerBottomConstant = headerTopConstant + headerEffectiveHeight
            updateHeaderConstants(top: headerTopConstant, bottom: headerBottomConstant)
        }
    }

    private func updateHeaderConstants(top: CGFloat, bottom: CGFloat) {
        if headerTopConstraint.constant != top {
            headerTopConstraint.constant = top
        }
        if headerBottomConstraint.constant != bottom {
            headerBottomConstraint.constant = bottom
        }
    }
}

extension HeaderViewLayoutCoordinator.HeaderScrollState {
    init(
        adjustedTopOffset: CGFloat,
        maxHeaderShift: CGFloat,
        safeAreaTop: CGFloat,
        contentViewTopOffset: CGFloat
    ) {
        if adjustedTopOffset < 0 {
            self = .stretched(adjustedTopOffset: adjustedTopOffset)
        } else if adjustedTopOffset >= maxHeaderShift, maxHeaderShift > 0 {
            self = .pinned
        } else {
            let isOverlapping = adjustedTopOffset >= (contentViewTopOffset - safeAreaTop)
            self = .shrinking(
                adjustedTopOffset: adjustedTopOffset,
                isContentViewOverlappingSafeArea: isOverlapping
            )
        }
    }
}
