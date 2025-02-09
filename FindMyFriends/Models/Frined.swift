//
//  User.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import Foundation
import CoreLocation

struct Frined: Hashable {
    let id: UUID
    let name: String
    let location: CLLocation
    let isPinned: Bool = false
    
    static func == (lhs: Frined, rhs: Frined) -> Bool {
        lhs.id == rhs.id
    }
}
