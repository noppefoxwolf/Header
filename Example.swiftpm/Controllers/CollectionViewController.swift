import UIKit
import Header
import SwiftUI

private enum Section: Int {
    case items
}

private struct Item: Hashable {
    let identifier = UUID()
    let username: String
    let text: String
    let timestamp: Date
    let imageName: String?
}

private struct PostRow: View {
    let item: Item

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.gray)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(item.username)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(RelativeDateTimeFormatter().localizedString(for: item.timestamp, relativeTo: Date()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(item.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                if let name = item.imageName {
                    Image(systemName: name)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 16) {
                    Label("Like", systemImage: "heart")
                    Label("Comment", systemImage: "bubble.right")
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
        .padding()
    }
}

final class CollectionViewController: UICollectionViewController {
    private let listLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
    private let cellCount: Int
    private let applyDelay: TimeInterval
    
    private let cellRegistration = UICollectionView.CellRegistration(
        handler: { (cell: UICollectionViewListCell, indexPath, item: Item) in
            cell.contentConfiguration = UIHostingConfiguration {
                PostRow(item: item)
            }
            .background(.background)
            .margins(.all, 0)
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
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = dataSource
        self.title = "タイムライン"
        
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
        let sampleTexts = [
            "Beautiful weather today! Just went for a walk ☀️",
            "Found a new cafe. The latte was fantastic ☕️",
            "Learning Swift. Diffable Data Source is so handy.",
            "Sharing a photo 📷",
            "Time to start the year-end cleanup!"
        ]
        let now = Date()
        let items: [Item] = (0..<cellCount).map { (idx: Int) -> Item in
            let username: String = "user_\(idx % 7)"
            let textIndex: Int = idx % sampleTexts.count
            let text: String = sampleTexts[textIndex]
            let secondsOffset: Int = idx * 600
            let timeInterval: TimeInterval = -TimeInterval(secondsOffset)
            let timestamp: Date = now.addingTimeInterval(timeInterval)
            let imageName: String? = (idx % 3 == 0) ? "photo" : nil
            return Item(
                username: username,
                text: text,
                timestamp: timestamp,
                imageName: imageName
            )
        }
        snapshot.appendItems(items, toSection: .items)
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

