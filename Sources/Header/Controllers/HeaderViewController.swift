public import UIKit

@MainActor
public protocol HeaderViewControllerDelegate: AnyObject {
    func headerViewController(_ headerViewController: HeaderViewController, scrollStateDidChange state: HeaderViewController.ScrollState)
}

public final class HeaderViewController: UIViewController {
    public enum ScrollState: Equatable {
        case stretched
        case shrinking(isContentViewOverlappingSafeArea: Bool)
        case pinned
    }
    
    public var scrollState: ScrollState = .shrinking(
        isContentViewOverlappingSafeArea: false
    ) {
        didSet {
            if oldValue != scrollState {
                onScrollStateChanged()
            }
        }
    }
    
    // MARK: - UI Elements
    public let headerView = HeaderView()
    
    public weak var delegate: HeaderViewControllerDelegate?
    
    public override var navigationItem: UINavigationItem {
        rootViewController.navigationItem
    }
    
    private var activeScrollView: UIScrollView? {
        activeScrollViewCoordinator.activeScrollView
    }
    
    private var headerViewHeight: CGFloat {
        headerView.headerViewHeight(for: view.bounds.width)
    }

    private var contentViewTopOffset: CGFloat {
        headerView.contentViewTopOffset(for: view.bounds.width)
    }

    private var minimumHeaderHeight: CGFloat {
        headerView.paletteHeight(for: view.bounds.width)
    }
    
    private var topInset: CGFloat {
        -view.safeAreaInsets.top
    }
    
    // MARK: - Child View Controller
    private let rootViewController: UIViewController
    
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private let headerLayoutGuide = UILayoutGuide()
    private lazy var headerTopConstraint: NSLayoutConstraint = {
        headerLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
    }()
    private lazy var headerBottomConstraint: NSLayoutConstraint = {
        headerLayoutGuide.bottomAnchor.constraint(equalTo: view.topAnchor, constant: headerViewHeight)
    }()
    
    private var headerViewLayoutCoordinator: HeaderViewLayoutCoordinator?
    private var pendingScrollOffsetSynchronizer: PendingScrollOffsetSynchronizer?
    private let scrollViewPanGestureRelay = ScrollViewPanGestureRelay()
    
    private lazy var additionalSafeAreaInsetsCoordinator = AdditionalSafeAreaInsetsCoordinator(
        rootViewController: rootViewController,
        inset: { [unowned self] in topInset },
        headerViewHeight: { [unowned self] in
            headerViewHeight
        },
        availableHeight: { [unowned self] in
            let availableHeight = view.safeAreaLayoutGuide.layoutFrame.height - minimumHeaderHeight
            return max(0, availableHeight)
        }
    )
    private lazy var activeScrollViewCoordinator = ActiveScrollViewCoordinator(
        onContentOffsetChange: { [weak self] scrollView in
            self?.applyHeaderLayout(for: scrollView)
        },
        onDidActivateScrollView: { [weak self] scrollView in
            guard let self else { return }
            scrollViewPanGestureRelay.updatePanGestureProxy(for: scrollView, in: view)
        }
    )
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
        
        pendingScrollOffsetSynchronizer = PendingScrollOffsetSynchronizer(
            activeScrollView: { [weak self] in self?.activeScrollView },
            minimumHeaderHeight: { [unowned self] in
                minimumHeaderHeight
            },
            safeAreaTop: { [unowned self] in
                view.safeAreaInsets.top
            }
        )
        
        embedViewController()
        setupHeaderView()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if let scrollView = rootViewController.contentScrollView(for: .top) {
            didFinishTransition(to: scrollView)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        additionalSafeAreaInsetsCoordinator.refresh()
        if let activeScrollView {
            applyHeaderLayout(for: activeScrollView)
        }
    }

    @MainActor deinit {
        pendingScrollOffsetSynchronizer?.stopObservingPendingScrollOffsets()
    }
    
    // MARK: - Setup
    private func setupHeaderView() {
        view.addLayoutGuide(headerLayoutGuide)
        headerBottomConstraint.priority = .defaultHigh
        headerViewLayoutCoordinator = HeaderViewLayoutCoordinator(
            headerTopConstraint: headerTopConstraint,
            headerBottomConstraint: headerBottomConstraint
        )
        NSLayoutConstraint.activate([
            headerTopConstraint,
            headerLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerBottomConstraint,
        ])
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerLayoutGuide.topAnchor),
            headerLayoutGuide.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerLayoutGuide.leadingAnchor),
            headerLayoutGuide.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
        ])
    }
    
    func willTransition(to pendingScrollViews: [UIScrollView]) {
        pendingScrollOffsetSynchronizer?.synchronizePendingScrollOffsets(pendingScrollViews)
        pendingScrollOffsetSynchronizer?.startObservingPendingScrollOffsets(pendingScrollViews)
        var observedScrollViews = pendingScrollViews
        if let activeScrollView {
            observedScrollViews.append(activeScrollView)
        }
        additionalSafeAreaInsetsCoordinator.updateObservedScrollViews(observedScrollViews)
    }
    
    func didFinishTransition(to scrollView: UIScrollView) {
        pendingScrollOffsetSynchronizer?.stopObservingPendingScrollOffsets()
        startObservingCurrentScrollView(scrollView)
        additionalSafeAreaInsetsCoordinator.updateObservedScrollViews([scrollView])
    }
    
    private func embedViewController() {
        addChild(rootViewController)
        view.addSubview(rootViewController.view)
        rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
        rootViewController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            rootViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
            rootViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor)
        ])
    }
    
    private func startObservingCurrentScrollView(_ scrollView: UIScrollView) {
        activeScrollViewCoordinator.startObserving(scrollView)
    }

    // MARK: - Observation
    private func applyHeaderLayout(for scrollView: UIScrollView) {
        guard let headerViewLayoutCoordinator else { return }
        let layoutState = headerViewLayoutCoordinator.calculateLayoutState(
            for: scrollView,
            inset: topInset,
            minimumHeaderHeight: minimumHeaderHeight,
            headerHeight: headerViewHeight,
            safeAreaTop: view.safeAreaInsets.top,
            contentViewTopOffset: contentViewTopOffset
        )
        headerViewLayoutCoordinator.applyLayout(
            state: layoutState.state,
            headerEffectiveHeight: layoutState.headerEffectiveHeight,
            maxHeaderShift: layoutState.maxHeaderShift
        )
        scrollState = ScrollState(from: layoutState.state)
    }
    
    private func onScrollStateChanged() {
        switch self.scrollState {
        case .shrinking(true), .pinned:
            setNavigationBarHidden(false, animated: true)
        default:
            setNavigationBarHidden(true, animated: true)
        }
        
        delegate?.headerViewController(self, scrollStateDidChange: scrollState)
    }
    
    private func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        func action() {
            func apply(_ appearance: UINavigationBarAppearance?, hidden: Bool) {
                if hidden {
                    appearance?.configureWithTransparentBackground()
                } else {
                    appearance?.configureWithOpaqueBackground()
                }
            }
            apply(navigationItem.compactAppearance, hidden: hidden)
            apply(navigationItem.standardAppearance, hidden: hidden)
            apply(navigationItem.scrollEdgeAppearance, hidden: hidden)
            apply(navigationItem.compactScrollEdgeAppearance, hidden: hidden)
        }
        
        if animated {
            UIView.transition(
                with: navigationBar,
                duration: CATransaction.animationDuration(),
                options: .transitionCrossDissolve
            ) { [weak navigationItem] in
                action()
            }
        } else {
            action()
        }
    }
}

private extension HeaderViewController.ScrollState {
    init(from state: HeaderViewLayoutCoordinator.HeaderScrollState) {
        switch state {
        case .stretched(let adjustedTopOffset):
            self = .stretched
        case .shrinking(_, let isContentViewOverlappingSafeArea):
            self = .shrinking(isContentViewOverlappingSafeArea: isContentViewOverlappingSafeArea)
        case .pinned:
            self = .pinned
        }
    }
}
