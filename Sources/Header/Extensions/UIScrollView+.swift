import UIKit
import Combine

extension UIScrollView {
    func fixContentOffset(_ targetContentOffset: CGPoint) -> AnyCancellable {
        Publishers.CombineLatest(
            Just(self),
            publisher(for: \.contentOffset)
        ).sink { (scrollView, contentOffset) in
            if contentOffset != targetContentOffset {
                scrollView.contentOffset = targetContentOffset
            }
        }
    }
}
