import UIKit

final class ToolbarBackgroundView: UIView {
    private let materialView = UIVisualEffectView(
        effect: UIBlurEffect(style: .regular)
    )
    private let hairlineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        materialView.frame = bounds

        let displayScale = max(traitCollection.displayScale, 1)
        let hairlineHeight = 1 / displayScale
        hairlineView.frame = CGRect(
            x: bounds.minX,
            y: bounds.maxY - hairlineHeight,
            width: bounds.width,
            height: hairlineHeight
        )
    }

    private func configureView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        materialView.isUserInteractionEnabled = false
        materialView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(materialView)

        hairlineView.backgroundColor = UIColor.separator.withAlphaComponent(0.22)
        hairlineView.isUserInteractionEnabled = false
        addSubview(hairlineView)
    }
}
