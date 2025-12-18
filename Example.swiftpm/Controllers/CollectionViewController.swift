import UIKit
import Header

private enum Section: Int {
    case items
}

private struct Item: Hashable {
    let identifier = UUID()
}

final class CollectionViewController: UICollectionViewController {
    private let listLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
    private let cellCount: Int
    private let applyDelay: TimeInterval
    
    private let cellRegistration = UICollectionView.CellRegistration(
        handler: { (cell: UICollectionViewListCell, indexPath, _: Item) in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = "\(indexPath)"
            cell.contentConfiguration = contentConfiguration
        }
    )
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let registration = cellRegistration
        return UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                collectionView.dequeueConfiguredReusableCell(
                    using: registration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }()
    
    init(title: String = "", cellCount: Int = 100, applyDelay: TimeInterval = 0) {
        self.cellCount = max(0, cellCount)
        self.applyDelay = max(0, applyDelay)
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.setCollectionViewLayout(listLayout, animated: false)
        collectionView.dataSource = dataSource
        
        if applyDelay == 0 {
            applySnapshot()
            return
        }
        Task { [weak self] in
            guard let self else { return }
            let nanoseconds = UInt64(applyDelay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            await MainActor.run {
                self.applySnapshot()
            }
        }
    }
}

private extension CollectionViewController {
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.items])
        snapshot.appendItems((0..<cellCount).map({ _ in Item() }), toSection: .items)
        dataSource.apply(snapshot)
    }
}

extension CollectionViewController: HeaderViewControllerDelegate {
    func headerViewController(_ headerViewController: HeaderViewController, scrollStateDidChange state: HeaderViewController.ScrollState) {
        switch state {
        case .shrinking(true), .pinned:
            title = "UICollectionViewController"
        default:
            title = nil
        }
    }
}
