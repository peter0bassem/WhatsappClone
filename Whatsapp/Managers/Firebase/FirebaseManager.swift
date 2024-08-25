//
//  FirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

enum FirebaseReferenceConstants {
    private static let databaseReference = Database.database().reference()
    static let UsersRef = databaseReference.child("users")
    static let ChannelsRef = databaseReference.child("channels")
    static let MessagesRef = databaseReference.child("channel-messages")
    static let UserChannelsRef = databaseReference.child("user-channels")
    static let UserDirectChannelsRef = databaseReference.child("user-direct-channels")
}

class FirebaseManager {
    static func configureApp() {
        FirebaseApp.configure()
    }
}

