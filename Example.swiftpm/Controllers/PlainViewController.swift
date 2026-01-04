import UIKit

final class PlainViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let safeAreaDashedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemRed.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 2
        layer.lineDashPattern = [6, 4] // 6pt dash, 4pt gap
        return layer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Center label setup
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Dashed safe area border layer
        view.layer.addSublayer(safeAreaDashedLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSafeAreaDashedPath()
    }

    private func updateSafeAreaDashedPath() {
        // Convert safe area layout guide's frame into view's coordinate space
        let path = UIBezierPath(rect: view.safeAreaLayoutGuide.layoutFrame)
        safeAreaDashedLayer.path = path.cgPath
        safeAreaDashedLayer.frame = view.bounds
    }
}

