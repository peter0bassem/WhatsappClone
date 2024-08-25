//
//  AuthFirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import CodableFirebase

enum AuthError: Error {
    case accountCreationFailed(_ description: String)
    case failedToSaveUserInfoToFirebase(_ description: String)
    case emailLoginFailed(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return description
        case .failedToSaveUserInfoToFirebase(let description):
            return description
        case .emailLoginFailed(let description):
            return description
        }
    }
}

actor AuthFirebaseManager {
    private static var databaseReference: DatabaseReference {
        Database.database().reference()
    }
    
    static func loginUser(loginRequest: LoginRequest) async throws -> User? {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: loginRequest.email, password: loginRequest.password)
            print("Successfully signed in \(authResult.user) ")
            return await fetchCurrentUserInfo()
        } catch {
            print("Failed to login user \(error.localizedDescription)")
            throw AuthError.emailLoginFailed(error.localizedDescription)
        }
    }
    
    static func createAccount(for username: String, email: String, password: String) async throws -> User? {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = User(uid: uid, username: username, email: email)
            try await saveUserInfoToFirebaseDatabase(user: newUser)
            return newUser
        } catch {
            print("🔐 Failed to create an account: \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(error.localizedDescription)
        }
    }
    
    private static func saveUserInfoToFirebaseDatabase(user: User) async throws {
        do {
            let userData = try FirebaseEncoder().encode(user)
            try await FirebaseReferenceConstants.UsersRef.child(user.uid).setValue(userData)
        } catch {
            print("🔐 Failed to save created user into firebase database: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfoToFirebase(error.localizedDescription)
        }
    }
    
    static func checkUserLoggedIn() async -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    static func fetchCurrentUserInfo() async -> User? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        do {
            let userSnapshot = try await FirebaseReferenceConstants.UsersRef.child(currentUid).getData()
            guard let value = userSnapshot.value else { return nil }
            let user = try FirebaseDecoder().decode(User.self, from: value)
            print("🔐 logged in user: \(user)")
            return user
        } catch {
            print("Failed to get current user info \(error.localizedDescription)")
            return nil
        }
        
//        return await withCheckedContinuation { continuation in
//            guard let currentUid = Auth.auth().currentUser?.uid else { /*continuation.resume(returning: nil);*/ return }
//            FirebaseReferenceConstants.usersRef.child(currentUid)
//                .observe(.value) { snapshot in
//                    guard let value = snapshot.value else { continuation.resume(returning: nil); return }
//                    do {
//                        let user = try FirebaseDecoder().decode(User.self, from: value)
//                        print("🔐 logged in user: \(user)")
//                        continuation.resume(returning: user)
//                    } catch {
//                        print("Failed to decode user snapshot.value \(error.localizedDescription)")
//                        return
//                    }
//                } withCancel: { error in
//                    print("Failed to get current user info \(error.localizedDescription)")
//                    return
//                }
//        }
    }
    
    static func getCurrentUserId() -> String? {
        Auth.auth().currentUser?.uid
    }
    
    static func logoutUser() async throws {
        do {
            try Auth.auth().signOut()
            print("🔐 Successfully logged out user")
        } catch {
            print("Failed to logout current user user \(error.localizedDescription)")
        }
    }
}
