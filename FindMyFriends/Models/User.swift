//
//  User.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import Foundation
import CoreLocation

struct User: Hashable {
    let id: UUID
    let name: String
    let location: CLLocation
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
