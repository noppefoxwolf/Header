import UIKit

public final class HeaderView: UIView {
    private let stackView = UIStackView()
    private var _backgroundView: UIView = EmptyView()
    private var _contentView: UIView = EmptyView()
    private var _paletteView: UIView = EmptyView()

    public var backgroundView: UIView {
        get { _backgroundView }
        set { setBackgroundView(newValue) }
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
        let targetSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let backgroundHeight = _backgroundView.systemLayoutSizeFitting(targetSize).height
        let contentHeight = _contentView.systemLayoutSizeFitting(targetSize).height
        let paletteHeight = _paletteView.systemLayoutSizeFitting(targetSize).height
        return backgroundHeight + contentHeight + paletteHeight
    }

    func contentViewTopOffset(for width: CGFloat) -> CGFloat {
        let targetSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let backgroundHeight = _backgroundView.systemLayoutSizeFitting(targetSize).height
        return backgroundHeight
    }

    func paletteHeight(for width: CGFloat) -> CGFloat {
        let targetSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        return _paletteView.systemLayoutSizeFitting(targetSize).height
    }

    private func setup() {
        stackView.backgroundColor = .systemBackground
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if _backgroundView.superview != nil {
            _backgroundView.removeFromSuperview()
        }
        if _contentView.superview != nil {
            _contentView.removeFromSuperview()
        }
        if _paletteView.superview != nil {
            _paletteView.removeFromSuperview()
        }
        
        stackView.addArrangedSubview(_backgroundView)
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

    private func setBackgroundView(_ newView: UIView) {
        guard newView !== _backgroundView else { return }

        stackView.replaceArrangedSubview(_backgroundView, with: newView, after: _backgroundView, fallbackIndex: 0)
        _backgroundView = newView

        newView.setContentHuggingPriority(.defaultLow, for: .vertical)
        newView.insetsLayoutMarginsFromSafeArea = false
        setNeedsLayout()
    }

    private func setContentView(_ newView: UIView) {
        guard newView !== _contentView else { return }

        stackView.replaceArrangedSubview(_contentView, with: newView, after: _backgroundView, fallbackIndex: 1)
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
