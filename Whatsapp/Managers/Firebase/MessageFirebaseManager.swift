//
//  MessageFirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation
import FirebaseDatabase
import CodableFirebase

actor MessageFirebaseManager {
    static func sendMessage(toChannel channelId: String, messageId: String, messageRequest: MessageRequest) throws {
        let encodedMessageRequest = try FirebaseEncoder().encode(messageRequest)
        FirebaseReferenceConstants.MessagesRef.child(channelId).child(messageId).setValue(encodedMessageRequest)
    }
}
