//
//  MessageItem.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import Foundation
import SwiftUI

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, MessageDirection.received].randomElement() ?? .sent
    }
    
}

struct MessageItem: Identifiable {
    let id = UUID().uuidString
    let text: String
    let direction: MessageDirection
    
    var backgroundColor: Color {
        return direction == .sent ? Color.bubbleGreen : Color.bubbleWhite
    }
    var alignment: Alignment {
        return direction == .received ? .leading : .trailing
    }
    var horizontalAlignment: HorizontalAlignment {
        return direction == .received ? .leading : .trailing
    }

    static let sentPlaceholder = MessageItem(text: "Holy Spagetti", direction: .sent)
    static let receivedPlaceholder = MessageItem(text: "Hey dude, whats up!", direction: .received)
}
