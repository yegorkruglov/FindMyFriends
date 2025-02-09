//
//  ProcessedUserData.swift
//  FindMyFriends
//
//  Created by Egor Kruglov on 09.02.2025.
//

import Foundation

struct ProcessedFriendData: Hashable {
    let id: UUID
    let name: String
    let distance: Double
    let isPinned: Bool
    let message: String
    
    static func == (lhs: ProcessedFriendData, rhs: ProcessedFriendData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
