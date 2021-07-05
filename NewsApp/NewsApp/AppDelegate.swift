//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Петр Блинов on 03.06.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let service = NetworkService()
        _ = CoreDataStack.shared
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = UITabBarController()
        let viewController = ViewController(networkService: service)
        let searchViewController = SearchViewController(networkService: service)
        let savedNewsViewController = SavedNewsViewController()
        
        window?.rootViewController = tabBarController
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: viewController),
            UINavigationController(rootViewController: searchViewController),
            UINavigationController(rootViewController: savedNewsViewController)]

        window?.makeKeyAndVisible()
        return true
    }
}

