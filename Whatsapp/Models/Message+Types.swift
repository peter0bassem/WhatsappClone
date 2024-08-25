//
//  Message+Types.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation

enum AdminMessageType: String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, MessageDirection.received].randomElement() ?? .sent
    }
    
}

enum MessageType: Equatable {
    case text(message: String)
    case photo
    case video
    case audio
}
