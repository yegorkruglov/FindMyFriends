//
//  User.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 06.02.2025.
//

import Foundation
import CoreLocation

struct User: Hashable {
    let name: String
    let location: CLLocation
}
