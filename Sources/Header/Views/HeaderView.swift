import UIKit

public final class HeaderView: UIView {
    private let stackView = UIStackView()
    private var _bannerView: UIView = EmptyView()
    private var _contentView: UIView = EmptyView()
    private var _paletteView: UIView = EmptyView()

    public var bannerView: UIView {
        get { _bannerView }
        set { setBannerView(newValue) }
    }
    
    public var contentView: UIView {
        get { _contentView }
        set { setContentView(newValue) }
    }

    public var paletteView: UIView {
        get { _paletteView }
        set { setPaletteView(newValue) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func headerViewHeight(for width: CGFloat) -> CGFloat {
        let bannerHeight = fittingHeight(of: _bannerView, for: width)
        let contentHeight = fittingHeight(of: _contentView, for: width)
        let paletteHeight = fittingHeight(of: _paletteView, for: width)
        return bannerHeight + contentHeight + paletteHeight
    }

    func contentViewTopOffset(for width: CGFloat) -> CGFloat {
        fittingHeight(of: _bannerView, for: width)
    }

    func paletteHeight(for width: CGFloat) -> CGFloat {
        fittingHeight(of: _paletteView, for: width)
    }

    private func fittingHeight(of view: UIView, for width: CGFloat) -> CGFloat {
        guard width.isFinite, width > 0 else { return 0 }

        // A finite compressed height prevents SwiftUI hosting views from
        // receiving CGFloat.greatestFiniteMagnitude as a layout proposal.
        let targetSize = CGSize(
            width: width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let height = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return height.isFinite ? max(0, height) : 0
    }

    private func setup() {
        backgroundColor = .systemBackground
        
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if _bannerView.superview != nil {
            _bannerView.removeFromSuperview()
        }
        if _contentView.superview != nil {
            _contentView.removeFromSuperview()
        }
        if _paletteView.superview != nil {
            _paletteView.removeFromSuperview()
        }
        
        stackView.addArrangedSubview(_bannerView)
        stackView.addArrangedSubview(_contentView)
        stackView.addArrangedSubview(_paletteView)
        _contentView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        _paletteView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
        ])
    }

    private func setBannerView(_ newView: UIView) {
        guard newView !== _bannerView else { return }

        stackView.replaceArrangedSubview(_bannerView, with: newView, after: _bannerView, fallbackIndex: 0)
        _bannerView = newView

        newView.setContentHuggingPriority(.defaultLow, for: .vertical)
        newView.insetsLayoutMarginsFromSafeArea = false
        setNeedsLayout()
    }

    private func setContentView(_ newView: UIView) {
        guard newView !== _contentView else { return }

        stackView.replaceArrangedSubview(_contentView, with: newView, after: _bannerView, fallbackIndex: 1)
        _contentView = newView

        newView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        newView.insetsLayoutMarginsFromSafeArea = false
        setNeedsLayout()
    }
    
    private func setPaletteView(_ newView: UIView) {
        guard newView !== _paletteView else { return }

        stackView.replaceArrangedSubview(_paletteView, with: newView, after: _contentView, fallbackIndex: 1)
        _paletteView = newView

        newView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        setNeedsLayout()
    }
    
    public var extendsContentViewHitArea: Bool = false

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard extendsContentViewHitArea else {
            return super.hitTest(point, with: event)
        }
        
        guard isUserInteractionEnabled,
              !isHidden,
              alpha > 0.01,
              contentView.isUserInteractionEnabled,
              !contentView.isHidden,
              contentView.alpha > 0.01 else {
            return super.hitTest(point, with: event)
        }
        let pointInContent = convert(point, to: contentView)
        if descendantHitExists(in: contentView, at: pointInContent, with: event) {
            return contentView
        }
        return super.hitTest(point, with: event)
    }
    
    private func descendantHitExists(in view: UIView, at pointInView: CGPoint, with event: UIEvent?) -> Bool {
        for subview in view.subviews.reversed() {
            guard subview.isUserInteractionEnabled,
                  !subview.isHidden,
                  subview.alpha > 0.01 else { continue }

            let pointInSubview = view.convert(pointInView, to: subview)
            guard subview.bounds.contains(pointInSubview) else { continue }
            if subview.hitTest(pointInSubview, with: event) != nil {
                return true
            }
            if descendantHitExists(in: subview, at: pointInSubview, with: event) {
                return true
            }
        }
        return false
    }
}

private extension UIStackView {
    func replaceArrangedSubview(_ oldView: UIView, with newView: UIView, after precedingView: UIView, fallbackIndex: Int) {
        removeArrangedSubviewIfNeeded(oldView)
        if newView.superview != nil {
            newView.removeFromSuperview()
        }
        let insertIndex = arrangedSubviewIndex(after: precedingView, fallbackIndex: fallbackIndex)
        insertArrangedSubview(newView, at: insertIndex)
    }

    func removeArrangedSubviewIfNeeded(_ view: UIView) {
        if arrangedSubviews.contains(view) {
            removeArrangedSubview(view)
        }
        view.removeFromSuperview()
    }

    func arrangedSubviewIndex(after view: UIView, fallbackIndex: Int) -> Int {
        guard let index = arrangedSubviews.firstIndex(of: view) else {
            return min(fallbackIndex, arrangedSubviews.count)
        }
        return min(index + 1, arrangedSubviews.count)
    }
}

private final class EmptyView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 0)
    }
}
