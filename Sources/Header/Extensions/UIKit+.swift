import UIKit

extension UIViewController {
    public var headerViewController: HeaderViewController? {
        parent as? HeaderViewController
    }
}

extension UIScrollView {
    public func willMove(to headerViewController: HeaderViewController) {
        headerViewController.willTransition(to: [self])
    }
    
    public func didMove(to headerViewController: HeaderViewController) {
        headerViewController.didFinishTransition(to: self)
    }
}
