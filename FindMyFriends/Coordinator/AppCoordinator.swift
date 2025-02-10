//
//  AppCoordinator.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 10.02.2025.
//

import UIKit
import CoreLocation

protocol AppCoordinatorProtocol {
    func start()
}

final class AppCoordinator: AppCoordinatorProtocol {
    
    private let window: UIWindow
    private let locationManager = CLLocationManager()
    private let navigationController: UINavigationController = UINavigationController()
    
    init(window: UIWindow) {
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func start() {
        switch locationManager.authorizationStatus {
            
        case .authorizedAlways, .authorizedWhenInUse:
            navigateToFrinedsList()
        default:
            navigateToLocationAuth()
        }
    }
    
    func navigateToLocationAuth() {
        let vm = LocationRequestViewModel(coordinator: self)
        let vc = LocationRequestViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func navigateToFrinedsList() {
        let vm = ViewModel()
        let vc = ViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: true)
    }
}
