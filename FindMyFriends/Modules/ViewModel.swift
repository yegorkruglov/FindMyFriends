//
//  ViewModel.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import Foundation
import Combine
import CoreLocation

class ViewModel {
    
    struct Input {
        let selectedUserPublisher: AnyPublisher<User?, Never>
    }
    
    struct Output {
        let usersPublisher: AnyPublisher<[User], Never>
    }
    
    // MARK: -  publisher
    
    private var cancellables: Set<AnyCancellable> = []
    let usersPublisher = PassthroughSubject<[User], Never>()
    
    // MARK: - private properties
    
    private let names: [String] = ["John", "Stephen", "Michael", "David", "Robert", "William", "James", "Charles", "Joseph", "Thomas"]
    private let userLocation: CLLocation = CLLocation(latitude: 30, longitude: 60)
    private var referenceLocation: CLLocation?
    
    // MARK: -  public methods
    
    func bind(_ input: ViewModel.Input) -> ViewModel.Output {
        
        
        viewDidLoad()
        
        
        input.selectedUserPublisher
            .sink { user in
                guard let user else { return }
                print(user.name)
            }
            .store(in: &cancellables)
        
        
        
        
        
        
        
        
        
        let output: ViewModel.Output = Output(
            usersPublisher: usersPublisher.eraseToAnyPublisher()
        )
        
        return output
    }
    
    // MARK: -  private methods
    
    private func viewDidLoad() {

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            usersPublisher.send(users)
        }
    }
    
    
}
