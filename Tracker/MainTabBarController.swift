import UIKit

final class MainTabBarController: UITabBarController {
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setupViewControllers()
    }

    private func configureTabBar() {
        tabBar.backgroundColor = .ypWhiteDay
        tabBar.tintColor = .ypBlue
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.backgroundDay.cgColor
        tabBar.clipsToBounds = true
    }

    private func setupViewControllers() {
        let trackersViewController = TrackersViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .imageTracker),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .imageStatistics),
            selectedImage: nil
        )

        viewControllers = [
            UINavigationController(rootViewController: trackersViewController),
            UINavigationController(rootViewController: statisticsViewController)
        ]
    }
}
