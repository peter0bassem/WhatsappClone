//
//  MessageService.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation
import Combine

protocol MessageService: Actor {
    static var shared: MessageService { get }
    func sendMessage(toChannel channelId: String, messageId: String, messageRequest: MessageRequest) throws
    func fetchUserChannels(withUserId userId: String) -> AnyPublisher<[Channel], Error>
    func sendTextMessage(toChannel channel: Channel, fromUser user: User, textMessage: String) async throws
    func getMessages(forChannel channel: Channel) -> AnyPublisher<[Message], Error>
}

/// Handle Sending, Receiving messages and setting Reactions
final actor MessageServiceImpl: MessageService {
    
    static var shared: MessageService = MessageServiceImpl()
    
    private init() { }
    
    func sendMessage(toChannel channelId: String, messageId: String, messageRequest: MessageRequest) throws {
        try MessageFirebaseManager.sendMessage(toChannel: channelId, messageId: messageId, messageRequest: messageRequest)
    }
    
    func fetchUserChannels(withUserId userId: String) -> AnyPublisher<[Channel], Error> {
        MessageFirebaseManager.fetchUserChannels(withUserId: userId)
    }
    
    func sendTextMessage(toChannel channel: Channel, fromUser user: User, textMessage: String) async throws {
        try await MessageFirebaseManager.sendTextMessage(toChannel: channel, fromUser: user, textMessage: textMessage)
    }
    
    func getMessages(forChannel channel: Channel) -> AnyPublisher<[Message], Error> {
        return MessageFirebaseManager.getMessages(forChannel: channel)
    }
}
