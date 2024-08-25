//
//  MessageService.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation

protocol MessageService: Actor {
    static var shared: MessageService { get }
    func sendMessage(toChannel channelId: String, messageId: String, messageRequest: MessageRequest) throws
}

final actor MessageServiceImpl: MessageService {
    
    static var shared: MessageService = MessageServiceImpl()
    
    private init() { }
    
    func sendMessage(toChannel channelId: String, messageId: String, messageRequest: MessageRequest) throws {
        try MessageFirebaseManager.sendMessage(toChannel: channelId, messageId: messageId, messageRequest: messageRequest)
    }
}
