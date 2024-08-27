//
//  ChannelService.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation

protocol ChannelService: Actor {
    static var shared: ChannelService { get }
    func createChannelIdKey() async -> String?
    func createChannel(_ channelRequest: ChannelCreationRequest, withChannelKey channelKey: String) throws
    func updateUserChannelIdValue(forUserId userId: String, channelId: String, value: Bool)
    func updateUserDirectChannelValue(forUserId userId: String, partnerId: String, channelId: String, value: Bool)
    func verifyDirectChatChannelExists(withUser userId: String, partnerId: String) async throws -> (snapshotExists: Bool, channelId: String?)
    func getChannel(forChannelId channelId: String) async throws -> Channel?
}

final actor ChannelServiceImp: ChannelService {
    
    static let shared: ChannelService = ChannelServiceImp()
    
    private init() { }
    
    func createChannelIdKey() async -> String? {
        ChannelFirebaseManager.createChannelIdKey()
    }
    
    func createChannel(_ channelRequest: ChannelCreationRequest, withChannelKey channelKey: String) throws {
        try ChannelFirebaseManager.createChannel(channelRequest, withChannelKey: channelKey)
    }
    
    func updateUserChannelIdValue(forUserId userId: String, channelId: String, value: Bool) {
        ChannelFirebaseManager.updateUserChannelIdValue(forUserId: userId, channelId: channelId, value: value)
    }
    
    func updateUserDirectChannelValue(forUserId userId: String, partnerId: String, channelId: String, value: Bool) {
        ChannelFirebaseManager.updateUserDirectChannelValue(forUserId: userId, partnerId: partnerId, channelId: channelId, value: value)
    }
    
    func verifyDirectChatChannelExists(withUser userId: String, partnerId: String) async throws -> (snapshotExists: Bool, channelId: String?) {
        try await ChannelFirebaseManager.verifyDirectChatChannelExists(withUser: userId, partnerId: partnerId)
    }
    
    func getChannel(forChannelId channelId: String) async throws -> Channel? {
        try await ChannelFirebaseManager.getChannel(forChannelId: channelId)
    }
}
