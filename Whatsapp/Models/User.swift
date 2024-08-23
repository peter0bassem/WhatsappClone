//
//  User.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation

struct User: Identifiable, Hashable, Codable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil
    var profileImageUrl: String? = nil
    
    var id: String {
        uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey There! I'm using WhatsApp."
    }
    
    static let placeholderUser = User(uid: "1", username: "Peter", email: "peter@gmail.com")
    
    static let placeholders: [User] = [
        User(uid: "1", username: "Osas", email: "Tosask@yahoo.com"),
        User(uid: "2", username: "JohnDoe", email: "johndoe@example.com", bio: "Hello, I'm John."),
        User(uid: "3", username: "Jane Smith", email: "janesmith@example.com", bio: "Passionate about coding."),
        User(uid: "4", username: "Alice", email: "alice@gmail.com", bio: "Tech enthusiast."),
        User(uid: "5", username: "Bob", email: "bob@example.com", bio: "Lover of nature."),
        User(uid: "6", username: "Ella", email: "ella@hotmail.com", bio: "Dreamer."),
        User(uid: "7", username: "Michael", email: "michael@gmail.com"),
        User(uid: "8", username: "Sophie", email: "sophie@example.com", bio: "Coffee addict >"),
        User(uid: "9", username: "David", email: "david@example.com", bio: "Music lover."),
        User(uid: "10", username: "Emily", email: "emily@yahoo.com", bio: "Travel enthusiast.")
    ]
}
