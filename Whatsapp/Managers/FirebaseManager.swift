//
//  FirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class FirebaseManager {
    private static var databaseReference: DatabaseReference {
        Database.database().reference()
    }
    static func configureApp() {
        FirebaseApp.configure()
    }
    
    static func createAccount(for username: String, email: String, password: String) async throws {
        // invoke firebase create account method: store the user in our firebase auth
        // store the new user info in our database.
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = authResult.user.uid
        let newUser = User(uid: uid, username: username, email: email)
        try await saveUserInfoToFirebaseDatabase(user: newUser)
    }
    
    private static func saveUserInfoToFirebaseDatabase(user: User) async throws {
        let userDictionary = [
            "uid": user.uid,
            "username": user.username,
            "email": user.email
        ]
        try await databaseReference.child("users").child(user.uid).setValue(userDictionary)
    }
}
