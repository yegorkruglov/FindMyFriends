//
//  ViewModel.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import Foundation
import Combine

struct ViewModel {
    private var cancellables: Set<AnyCancellable> = []
    
    private let names: [String] = ["John", "Stephen", "Michael", "David", "Robert", "William", "James", "Charles", "Joseph", "Thomas"]
    
    let usersPublisher = PassthroughSubject<[User], Never>()
    
    func viewDidLoad() {
        let users = names.map({ User(id: UUID(), name: $0) })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            usersPublisher.send(users)
        }
    }
    
    
}
