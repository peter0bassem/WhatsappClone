//
//  Message.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import Foundation
import SwiftUI

struct Message: Identifiable {
    let id = UUID().uuidString
    let text: String
    let type: MessageType
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
    
    static let stubMessages: [Message] = [
        .init(text: "Hello, World! How are you doing?", type: .text(message: ""), direction: .sent),
        .init(text: "Check out this Photo!", type: .photo, direction: .received),
        .init(text: "Play this video", type: .video, direction: .sent),
        .init(text: "Listen to this audio", type: .audio, direction: .sent),
        .init(text: "", type: .audio, direction: .received),
    ]

    static let sentPlaceholder = Message(text: "Holy Spagetti, this is a dummy text for multi-line text view testing purpose.", type: .text(message: ""), direction: .sent)
    static let receivedPlaceholder = Message(text: "", type: .text(message: ""), direction: .received) //Hey dude, whats up!
}
