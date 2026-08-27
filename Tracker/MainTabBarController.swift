import UIKit

final class MainTabBarController: UITabBarController {

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
        let trackersViewController = TrackersViewController()
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
