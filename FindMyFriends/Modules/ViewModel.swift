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
    private lazy var usersPublisher = CurrentValueSubject<[User], Never>([])
    private lazy var userUpdatePublisher = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    
    // MARK: - private properties
    
    private let names: [String] = [
        "John Smith",
        "Helen Row",
        "Michael Johnson",
        "Sophia Brown",
        "James Garcia",
        "Olivia Miller",
        "Benjamin Davis",
        "Isabella Rodriguez",
        "Daniel Martinez",
        "Mia Hernandez",
        "Matthew Lopez",
        "Charlotte Gonzalez",
        "Ethan Wilson",
        "Amelia Anderson",
        "William Thomas",
        "Harper Taylor",
        "Henry Moore",
        "Evelyn Jackson",
        "Joseph Martin",
        "Abigail White"
    ]
    
    private let userLocation: CLLocation = CLLocation(latitude: 30, longitude: 60)
    private var selectedUserLocation: CLLocation?
    
    // MARK: -  public methods
    
    func bind(_ input: ViewModel.Input) -> ViewModel.Output {
        viewDidLoad()
        
        handleSelectedUserPublisher(input.selectedUserPublisher)
        handleUserUpdatePublisher()
        
        return Output(
            usersPublisher: usersPublisher.eraseToAnyPublisher()
        )
    }
}

// MARK: -  private methods
private extension ViewModel {
    func viewDidLoad() {
        
        let users = generateUsers(.new(userLocation: userLocation))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            usersPublisher.send(users)
        }
    }
    
    func handleSelectedUserPublisher(_ publisher: AnyPublisher<User?, Never>) {
        publisher
            .sink { user in
                print(user?.name ?? "No user selected")
            }
            .store(in: &cancellables)
    }
    
    func generateUsers(_ type: LocationType) -> [User] {
        
        let users: [User]
        let delta: Double
       
        switch type {
        
        case .new(let userLocation):
            delta = 0.5
            users = names.map { name in
                User(
                    name: name,
                    location: generateRandomLocationRelativeTo(userLocation, withDelta: delta)
                )
            }
            
        case .fromUsersOld(let oldUsers):
            delta = 0.01
            users = oldUsers.map { oldUser in
                User(
                    name: oldUser.name,
                    location: generateRandomLocationRelativeTo(
                        oldUser.location,
                        withDelta: delta
                    )
                )
            }
        }
        
        return users
    }
    
    func generateRandomLocationRelativeTo(_ location: CLLocation, withDelta delta: Double) -> CLLocation {
        
        let latMax = userLocation.coordinate.latitude + delta
        let latMin = userLocation.coordinate.latitude - delta
        let longMax = userLocation.coordinate.longitude + delta
        let longMin = userLocation.coordinate.longitude - delta
        
        let newRandomLatitude = Double.random(in: latMin...latMax)
        let newRandomLongitude = Double.random(in: longMin...longMax)
        
        return CLLocation(latitude: newRandomLatitude, longitude: newRandomLongitude)
    }
    
    func handleUserUpdatePublisher() {
        userUpdatePublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let newUsers = generateUsers(.fromUsersOld(oldUsers: usersPublisher.value))
                print(newUsers.first?.location.coordinate)
                usersPublisher.send(newUsers)
            }
            .store(in: &cancellables)
    }
}

enum LocationType {
    case new(userLocation: CLLocation)
    case fromUsersOld(oldUsers: [User])
}
