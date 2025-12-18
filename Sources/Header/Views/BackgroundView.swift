import UIKit

@MainActor
protocol BackgroundView: UIView {
    var topContentMargin: CGFloat { get }
    var contentView: UIView? { get set }
}

@MainActor
func makeCompatibleBackgroundView() -> BackgroundView {
    if #available(iOS 26.0, *) {
        // FIXME: Invalid frame dimension (negative or non-finite). が発生する
        BackgroundExtensionView()
    } else {
        LegacyBackgroundView()
    }
}

final class LegacyBackgroundView: UIView, BackgroundView {
    var topConstraint: NSLayoutConstraint? = nil
    
    var topContentMargin: CGFloat {
        topConstraint?.constant ?? 0
    }
    
    var contentView: UIView? = nil {
        didSet {
            if let contentView {
                contentView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(contentView)
                topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
                topConstraint!.priority = .defaultHigh
                NSLayoutConstraint.activate([
                    topConstraint!,
                    bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                ])
            } else if let oldValue {
                oldValue.removeFromSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        topConstraint?.constant = statusBarHeight
    }
}

@available(iOS 26.0, *)
final class BackgroundExtensionView: UIView, BackgroundView {
    let internalView = UIBackgroundExtensionView()
    var topConstraint: NSLayoutConstraint? = nil
    
    var topContentMargin: CGFloat {
        topConstraint?.constant ?? 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        internalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(internalView)
        NSLayoutConstraint.activate([
            internalView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: internalView.bottomAnchor),
            internalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: internalView.trailingAnchor),
        ])
    }
    
    var contentView: UIView? = nil {
        didSet {
            if let contentView {
                internalView.contentView = contentView
                internalView.automaticallyPlacesContentView = false
                topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
                topConstraint!.priority = .defaultHigh
                NSLayoutConstraint.activate([
                    topConstraint!,
                    bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                ])
            } else if let oldValue {
                oldValue.removeFromSuperview()
                internalView.contentView = nil
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        topConstraint?.constant = statusBarHeight
    }
}
