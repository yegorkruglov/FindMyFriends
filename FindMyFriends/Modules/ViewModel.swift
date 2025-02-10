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
        let selectedFriendPublisher: AnyPublisher<UUID?, Never>
    }
    
    struct Output {
        let processedDataPublisher: AnyPublisher<[ProcessedFriendData], Never>
    }
    
    // MARK: -  publisher
    
    private var cancellables: Set<AnyCancellable> = []
    private lazy var friendsPublisher = CurrentValueSubject<[Frined], Never>([])
    private lazy var friendsUpdatePublisher = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private lazy var processedFriendsDataPublisher = PassthroughSubject<[ProcessedFriendData], Never>()
    
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
    private var selectedFriendLocation: CLLocation?
    
    // MARK: -  public methods
    
    func bind(_ input: ViewModel.Input) -> ViewModel.Output {
        viewDidLoad()
        
        handleFriendsPublisher()
        handleFriendUpdatePublisher()
        handleSelectedFriendPublisher(input.selectedFriendPublisher)
        
        return Output(
            processedDataPublisher: processedFriendsDataPublisher.eraseToAnyPublisher()
        )
    }
}

// MARK: -  private methods
private extension ViewModel {
    func viewDidLoad() {
        
        let friends = generateFriends(.new(userLocation: userLocation))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            friendsPublisher.send(friends)
        }
    }
    
    func handleFriendsPublisher() {
        friendsPublisher
            .sink { [weak self] friends in
                guard let self else { return }
                let proccessedData = processFriendsData(friends)
                processedFriendsDataPublisher.send(proccessedData)
            }
            .store(in: &cancellables)
    }
    
    func handleSelectedFriendPublisher(_ publisher: AnyPublisher<UUID?, Never>) {
        publisher
            .sink { [weak self] id in
                guard let self else { return }
                
                if let index = friendsPublisher.value.firstIndex(where: { $0.id == id }) {
                    var newFriends = friendsPublisher.value
                    
                    if !newFriends[index].isPinned && newFriends.filter({ $0.isPinned }).count == 3 {
                        return
                    }
                    
                    newFriends[index].isPinned.toggle()
                    friendsPublisher.send(newFriends)
                }
            }
            .store(in: &cancellables)
    }
    
    func handleFriendUpdatePublisher() {
        friendsUpdatePublisher
            .sink { [weak self] _ in
                
                guard let self else { return }
                
                let newFriends = generateFriends(.fromOldData(data: friendsPublisher.value))
                friendsPublisher.send(newFriends)
            }
            .store(in: &cancellables)
    }
    
    func generateFriends(_ type: LocationType) -> [Frined] {
        
        let friends: [Frined]
        let delta: Double
        
        switch type {
            
        case .new(let userLocation):
            delta = 0.5
            friends = names.map { name in
                Frined(
                    id: UUID(),
                    name: name,
                    location: generateRandomLocationRelativeTo(userLocation, withDelta: delta)
                )
            }
            
        case .fromOldData(let oldFriends):
            delta = 0.001
            friends = oldFriends.map { oldFriend in
                Frined(
                    id: oldFriend.id,
                    name: oldFriend.name,
                    location: generateRandomLocationRelativeTo(
                        oldFriend.location,
                        withDelta: delta
                    ),
                    isPinned: oldFriend.isPinned
                )
            }
        }
        
        return friends
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
    
    func calculateDistance(from location1: CLLocation, to location2: CLLocation) -> Double {
        return location1.distance(from: location2)
    }
    
    func processFriendsData(_ friends: [Frined]) -> [ProcessedFriendData] {
        let pinnedFriends = friends.filter { $0.isPinned }
        let processedData: [ProcessedFriendData]
        
        if pinnedFriends.count == 1, let singlePinnedFriend = pinnedFriends.first {
            processedData = friends.map { friend in
                let distance = self.calculateDistance(from: singlePinnedFriend.location, to: friend.location)
                let formattedValue = String(format: "%.2f", distance)
                let message = "\(formattedValue) meters away from \(singlePinnedFriend.name)"
                let altMessage = "Showing distance from this person to others"
                return ProcessedFriendData(
                    id: friend.id,
                    name: friend.name,
                    distance: friend == singlePinnedFriend ? 0 : distance,
                    isPinned: friend.isPinned,
                    message: friend == singlePinnedFriend ? altMessage : message
                )
            }
        } else {
            processedData = friends.map { friend in
                let distance = self.calculateDistance(from: self.userLocation, to: friend.location)
                let formattedValue = String(format: "%.2f", distance)
                let message = "\(formattedValue) meters from you"
                return ProcessedFriendData(
                    id: friend.id,
                    name: friend.name,
                    distance: distance,
                    isPinned: friend.isPinned,
                    message: message
                )
            }
        }
        return processedData
    }
}

enum LocationType {
    case new(userLocation: CLLocation)
    case fromOldData(data: [Frined])
}
