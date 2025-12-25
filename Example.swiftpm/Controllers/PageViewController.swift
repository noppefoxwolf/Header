import UIKit
import Header

final class PageViewController: UIPageViewController {
    private(set) var pages: [UIViewController]
    
    init(pages: [UIViewController] = PageViewController.makeDefaultPages()) {
        self.pages = pages
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        if #available(iOS 26.0, *) {
            let scrollView = value(forKey: "_scrollView") as! UIScrollView
            scrollView.topEdgeEffect.isHidden = true
        }
        
        if let targetViewController = pages.first {
            setViewControllers([targetViewController], direction: .forward, animated: false) { [weak self] finished in
                guard let self else { return }
                guard finished else { return }
                let contentScrollView = targetViewController.contentScrollView(for: .top)!
                contentScrollView.didMove(to: headerViewController!)
            }
        }
    }
    
    var currentViewController: UIViewController? {
        viewControllers?.first
    }
    
    var horizontalScrollView: UIScrollView {
        view.subviews.compactMap { $0 as? UIScrollView }.first!
    }

    func selectPage(at index: Int, animated: Bool = true) {
        guard pages.indices.contains(index) else { return }
        let targetViewController = pages[index]
        guard currentViewController !== targetViewController else { return }
        let direction: UIPageViewController.NavigationDirection
        if let currentViewController,
           let currentIndex = pages.firstIndex(where: { $0 === currentViewController }) {
            direction = index > currentIndex ? .forward : .reverse
        } else {
            direction = .forward
        }

        targetViewController.loadViewIfNeeded()
        let contentScrollView = targetViewController.contentScrollView(for: .top)!
        contentScrollView.willMove(to: headerViewController!)
        setViewControllers([targetViewController], direction: direction, animated: animated) { [weak self] finished in
            guard let self else { return }
            guard finished else { return }
            contentScrollView.didMove(to: headerViewController!)
        }
    }
}
 
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(where: { $0 === viewController }) else { return nil }
        guard index != 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(where: { $0 === viewController }) else { return nil }
        guard index != pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let scrollView = pendingViewControllers.compactMap({ $0.contentScrollView(for: .top) })[0]
        scrollView.willMove(to: headerViewController!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished, completed else { return }
        if let scrollView = currentViewController?.contentScrollView(for: .top) {
            scrollView.didMove(to: headerViewController!)
        }
    }
}

extension PageViewController: HeaderViewControllerDelegate {
    func headerViewController(_ headerViewController: HeaderViewController, scrollStateDidChange state: HeaderViewController.ScrollState) {
        switch state {
        case .shrinking(true), .pinned:
            title = "UIPageViewController"
        default:
            title = nil
        }
    }
}


private extension PageViewController {
    static func makeDefaultPages() -> [UIViewController] {
        [
            CollectionViewController(title: "CollectionView:1", cellCount: 100),
            CollectionViewController(title: "CollectionView:2", cellCount: 3, applyDelay: 3),
            CollectionViewController(title: "CollectionView:3", cellCount: 100),
            CollectionViewController(title: "CollectionView:4", cellCount: 10),
            CollectionViewController(title: "CollectionView:5", cellCount: 100),
        ]
    }
}
