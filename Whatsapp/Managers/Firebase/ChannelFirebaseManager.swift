//
//  ChannelFirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation
import FirebaseDatabase
import CodableFirebase

actor ChannelFirebaseManager {
    static func createChannelIdKey() -> String? {
        FirebaseReferenceConstants.ChannelsRef.childByAutoId().key
    }
    
    static func createChannel(_ channelRequest: ChannelCreationRequest, withChannelKey channelKey: String) throws {
        let encodedChannelRequest = try FirebaseEncoder().encode(channelRequest)
        FirebaseReferenceConstants.ChannelsRef.child(channelKey).setValue(encodedChannelRequest)
    }
    
//    func crreateChatMessage(_ messageRequest: ChannelCreationRequest, withChannelKey channelKey: String) async throws {
//        
//    }
    
    static func updateUserChannelIdValue(forUserId userId: String, channelId: String, value: Bool) {
        FirebaseReferenceConstants.UserChannelsRef.child(userId).child(channelId).setValue(value)
    }
    
    static func updateUserDirectChannelValue(forUserId userId: String, partnerId: String, channelId: String, value: Bool) {
        FirebaseReferenceConstants.UserDirectChannelsRef.child(userId).child(partnerId).setValue([channelId: value])
    }
    
    static func verifyDirectChatChannelExists(withUser userId: String, partnerId: String) async throws -> (snapshotExists: Bool, channelId: String?) {
        let snapshot = try await FirebaseReferenceConstants.UserDirectChannelsRef.child(userId).child(partnerId).getData()
        guard let directMessageDict = snapshot.value as? [String: Bool] else { return (false, nil) }
        let channelId = directMessageDict.compactMap { $0.key }.first
        return (snapshot.exists(), channelId)
    }
    
    static func getChannel(forChannelId channelId: String) async throws -> Channel? {
        let snapshot = try await FirebaseReferenceConstants.ChannelsRef.child(channelId).getData()
        guard let value = snapshot.value else { return nil }
        let channel = try FirebaseDecoder().decode(Channel.self, from: value)
        return channel
    }
}
