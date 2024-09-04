//
//  FirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage

enum FirebaseReferenceConstants {
    static let StorageReference = Storage.storage().reference()
    private static let DatabaseReference = Database.database().reference()
    static let UsersRef = DatabaseReference.child("users")
    static let ChannelsRef = DatabaseReference.child("channels")
    static let MessagesRef = DatabaseReference.child("channel-messages")
    static let UserChannelsRef = DatabaseReference.child("user-channels")
    static let UserDirectChannelsRef = DatabaseReference.child("user-direct-channels")
}

class FirebaseManager {
    static func configureApp() {
        FirebaseApp.configure()
    }
}

