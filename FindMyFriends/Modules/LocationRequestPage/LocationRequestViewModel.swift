//
//  LocationRequestViewModel.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 10.02.2025.
//

import Foundation
import Combine
import CoreLocation

final class LocationRequestViewModel: NSObject {
    
    // MARK: - private properties
    
    private let appCoordinator: AppCoordinator
    private let locationManager = CLLocationManager()
    private let locationAuthStatusPublisher = PassthroughSubject<CLAuthorizationStatus, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - initilizers
    
    init(coordinator: AppCoordinator) {
        self.appCoordinator = coordinator
        super.init()
        locationManager.delegate = self
        handleLocationAuthStatusPublisher()
    }
    
    // MARK: - public methods
    
    func didPressAccessButton() {
        switch locationManager.authorizationStatus {
            
        case .notDetermined, .restricted, .denied:
            requestLocationAccess()
        default:
            break
        }
    }
    
    // MARK: - private methods
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func handleLocationAuthStatusPublisher() {
        locationAuthStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                switch value {
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.appCoordinator.navigateToFrinedsList()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}


// MARK: - CLLocationManagerDelegate

extension LocationRequestViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthStatusPublisher.send(manager.authorizationStatus)
    }
}

