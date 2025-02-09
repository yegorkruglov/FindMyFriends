//
//  ViewModel.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import Foundation
import Combine
import CoreLocation

struct ViewModel {
    let usersPublisher = PassthroughSubject<[User], Never>()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let names: [String] = ["John", "Stephen", "Michael", "David", "Robert", "William", "James", "Charles", "Joseph", "Thomas"]
    
    private let userLocation: CLLocation = CLLocation(latitude: 30, longitude: 60)
    
    private var referenceLocation: CLLocation?
    
    func viewDidLoad() {

        let users = names.map { name in
            
            let latMax = userLocation.coordinate.latitude + 0.5
            let latMin = userLocation.coordinate.latitude - 0.5
            let longMax = userLocation.coordinate.longitude + 0.5
            let longMin = userLocation.coordinate.longitude - 0.5
            
            let newRandomLatitude = Double.random(in: latMin...latMax)
            let newRandomLongitude = Double.random(in: longMin...longMax)
            
            let newRandomLocation = CLLocation(latitude: newRandomLatitude, longitude: newRandomLongitude)
            
            let distanceToReference = referenceLocation?.distance(from: userLocation)
            
            return User(
                id: UUID(),
                name: name,
                location: newRandomLocation
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            usersPublisher.send(users)
        }
    }
}
