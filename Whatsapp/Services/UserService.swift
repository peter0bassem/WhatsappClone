//
//  UserService.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation

protocol UserService: Actor {
    static var shared: UserService { get }
    func paginateUsers(lastCursor: String?, pageSize: UInt) async throws -> UserNode
}

actor UserServiceImp: UserService {
    
    static var shared: UserService = UserServiceImp()
    
    func paginateUsers(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
        return try await UserFirebaseManager.initialUsersFetch(lastCursor: lastCursor, pageSize: pageSize)
    }
}
