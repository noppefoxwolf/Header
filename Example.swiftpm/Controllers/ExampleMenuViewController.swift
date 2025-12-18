import UIKit
import Header

final class ExampleMenuViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case demos
        case options
    }
    
    private enum Demo: CaseIterable {
        case pageViewController
        case singleCollectionViewController
        case pagerPageViewController
        
        var title: String {
            switch self {
            case .pageViewController:
                return "UIPageViewController Sample"
            case .singleCollectionViewController:
                return "Single CollectionView Sample"
            case .pagerPageViewController:
                return "Pager.PageViewController Sample"
            }
        }
        
        var subtitle: String {
            switch self {
            case .pageViewController:
                return "Swipe between multiple collection pages"
            case .singleCollectionViewController:
                return "One collection view with stretch header"
            case .pagerPageViewController:
                return "Swipe between multiple collection pages"
            }
        }
     
        @MainActor
        func makeRootViewController() -> UIViewController & HeaderViewControllerDelegate {
            switch self {
            case .pageViewController:
                return PageViewController()
            case .singleCollectionViewController:
                return CollectionViewController(title: "CollectionView")
            case .pagerPageViewController:
                return PagerPageViewController(pages: PagerPageViewController.makeDefaultPages())
            }
        }
    }
    
    private let demos = Demo.allCases
    private let cellReuseIdentifier = "DemoCell"
    private let switchCellReuseIdentifier = "SwitchCell"
    private var paletteEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Header Examples"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: switchCellReuseIdentifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .demos:
            return demos.count
        case .options:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .demos:
            let demo = demos[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = demo.title
            content.secondaryText = demo.subtitle
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        case .options:
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellReuseIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Palette"
            cell.contentConfiguration = content
            let toggle = UISwitch()
            toggle.isOn = paletteEnabled
            toggle.addTarget(self, action: #selector(paletteSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), section == .demos else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let demo = demos[indexPath.row]
        let rootViewController = demo.makeRootViewController()
        let palette: HeaderDemoFactory.Palette = paletteEnabled ? .automatic : .none
        let headerViewController = HeaderDemoFactory.make(
            rootViewController: rootViewController,
            palette: palette
        )
        headerViewController.title = demo.title
        navigationController?.pushViewController(headerViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        switch section {
        case .demos:
            return "Samples"
        case .options:
            return "Options"
        }
    }
    
    @objc private func paletteSwitchChanged(_ sender: UISwitch) {
        paletteEnabled = sender.isOn
    }
}
