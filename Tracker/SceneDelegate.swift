//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Dmitrii Pogonia on 12.08.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let coreDataStack = CoreDataStack()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    private func makeRootViewController() -> UIViewController {
        if OnboardingStorage.hasCompletedOnboarding {
            return makeMainTabBarController()
        }

        return OnboardingViewController { [weak self] in
            guard let self, let window = self.window else { return }
            window.rootViewController = self.makeMainTabBarController()
        }
    }

    private func makeMainTabBarController() -> MainTabBarController {
        let trackerStore = TrackerStore(context: coreDataStack.context)
        let categoryStore = TrackerCategoryStore(context: coreDataStack.context)
        let recordStore = TrackerRecordStore(context: coreDataStack.context)
        return MainTabBarController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
    }
}
