//
//  Message.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import Foundation
import SwiftUI

struct Message: Identifiable, Codable {
    var id: String?
    let text: String?
    let type: MessageType?
    let ownerId: String?
    let timestamp: TimeInterval?
    var direction: MessageDirection {
        get async {
            ownerId == (await AuthProviderServiceImp.shared.getCurrentUserId() ?? "RfZDo1E35IVnZUH4C14pEgr7wxH2"/*.removeOptional*/) ? .sent : .received
        }
    }
    
    var backgroundColor: Color {
        get async {
            return (await direction) == .sent ? Color.bubbleGreen : Color.bubbleWhite
        }
    }
    var alignment: Alignment {
        get async {
            return (await direction) == .received ? .leading : .trailing
        }
    }
    var horizontalAlignment: HorizontalAlignment {
        get async {
            return (await direction) == .received ? .leading : .trailing
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        self.type = MessageType(type ?? "")
        self.ownerId = try container.decodeIfPresent(String.self, forKey: .ownerId)
        self.timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }
    
    init(id: String?, text: String?, type: MessageType?, ownerId: String?, timestamp: TimeInterval?) {
        self.id = id
        self.text = text
        self.type = type
        self.ownerId = ownerId
        self.timestamp = timestamp
    }
    
    static let stubMessages: [Message] = [
        Message(id: UUID().uuidString, text: "Hi There", type: .text, ownerId: "RfZDo1E35IVnZUH4C14pEgr7wxH2", timestamp: nil),
        Message(id: UUID().uuidString, text: "Check out this Photo", type: .photo, ownerId: "4", timestamp: nil),
        Message(id: UUID().uuidString, text: "Play out this Video", type: .video, ownerId: "5", timestamp: nil),
        Message(id: UUID().uuidString, text: "", type: .audio, ownerId: "6", timestamp: nil)
    ]

    static let sentPlaceholder = Message(id: UUID().uuidString, text: "Holy Spagetti, this is a dummy text for multi-line text view testing purpose.", type: .text, ownerId: "RfZDo1E35IVnZUH4C14pEgr7wxH2", timestamp: nil)
    static let receivedPlaceholder = Message(id: UUID().uuidString, text: "", type: .text, ownerId: "2", timestamp: nil)
}
