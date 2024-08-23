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
}
