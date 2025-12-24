import UIKit

@available(iOS 26.0, *)
final class HeaderBackgroundView: UIBackgroundExtensionView {
    
    var topConstraint: NSLayoutConstraint? = nil {
        didSet { setNeedsLayout() }
    }
    
    override var contentView: UIView? {
        didSet {
            if let contentView {
                contentView.translatesAutoresizingMaskIntoConstraints = false
                automaticallyPlacesContentView = false
                topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
                NSLayoutConstraint.activate([
                    topConstraint!,
                    bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                ])
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topConstraint?.constant = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
}
