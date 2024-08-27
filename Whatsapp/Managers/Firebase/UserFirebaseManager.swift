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
                return try await FirebaseReferenceConstants.UsersRef
                    .queryLimited(toLast: pageSize)
                    .getData()
            } else {
                return try await FirebaseReferenceConstants.UsersRef
                    .queryOrderedByKey()
                    .queryEnding(atValue: lastCursor)
                    .queryLimited(toLast: pageSize + 1)
                    .getData()
            }
        }()
        async let totalUsersDataSnapshot = try await FirebaseReferenceConstants.UsersRef.getData()
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
    
    static func getUsers(withUserIds userIds: [String]) async -> [User] {
        return await withCheckedContinuation { continuation in
            Task {
                do {
                    let users = try await withThrowingTaskGroup(of: User?.self) { group in
                        for userId in userIds {
                            group.addTask {
                                let snapshot = try await FirebaseReferenceConstants.UsersRef.child(userId).getData()
                                guard let value = snapshot.value else { return nil }
                                return try FirebaseDecoder().decode(User.self, from: value)
                            }
                        }
                        
                        var collectedUsers: [User] = []
                        for try await user in group {
                            if let user = user {
                                collectedUsers.append(user)
                            }
                        }
                        return collectedUsers
                    }
                    continuation.resume(returning: users)
                } catch {
                    print("Failed to fetch users: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
}

struct UserNode {
    var users: [User]
    var currentCursor: String?
    var totalUsersCount: Int
    
    static let emptyNode = UserNode(users: [], currentCursor: nil, totalUsersCount: 0)
}
