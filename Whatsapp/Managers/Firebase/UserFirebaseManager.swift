//
//  UserFirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation
import FirebaseDatabase
import CodableFirebase

actor UserFirebaseManager {
    static func initialUsersFetch(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
        async let mainDaaSnapshot: DataSnapshot = {
            if lastCursor == nil {
                return try await FirebaseReferenceConstants.usersRef
                    .queryLimited(toLast: pageSize)
                    .getData()
            } else {
                return try await FirebaseReferenceConstants.usersRef
                    .queryOrderedByKey()
                    .queryEnding(atValue: lastCursor)
                    .queryLimited(toLast: pageSize + 1)
                    .getData()
            }
        }()
        async let totalUsersDataSnapshot = try await FirebaseReferenceConstants.usersRef.getData()
        let (mainSnapshot, totalUsersSnapshot) = try await (mainDaaSnapshot, totalUsersDataSnapshot)
        let value = mainSnapshot.children.compactMap { ($0 as? DataSnapshot)?.value } as Any
        let firstUserValueKey = mainSnapshot.children.map { ($0 as? DataSnapshot)?.key }.first ?? ""
        let users = try FirebaseDecoder().decode([User].self, from: value)
        if users.count == mainSnapshot.childrenCount {
            let filteredUsers = lastCursor == nil ? users : users.filter { $0.uid != lastCursor }
            let userNode = UserNode(users: filteredUsers, currentCursor: firstUserValueKey, totalUsersCount: Int(totalUsersSnapshot.childrenCount))
            return userNode
        }
        return .emptyNode
    }
}

struct UserNode {
    var users: [User]
    var currentCursor: String?
    var totalUsersCount: Int
    
    static let emptyNode = UserNode(users: [], currentCursor: nil, totalUsersCount: 0)
}
