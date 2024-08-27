//
//  Message+Types.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation

enum AdminMessageType: String, Codable {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageDirection: Codable {
    case unset,sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, MessageDirection.received].randomElement() ?? .sent
    }
    
}

enum MessageType: Equatable, Codable {
    case admin(type: AdminMessageType)
    case text//(message: String)
    case photo
    case video
    case audio
    
    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text/*(let message)*/:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        }
        
        
    }
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "text": self = .text
        case "photo": self = .photo
        case "video": self = .video
        case "audio": self = .audio
        default: 
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(type: adminMessageType)
            } else {
                return nil
            }
        }
    }
}
