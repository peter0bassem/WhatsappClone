//
//  AuthProviderService.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import Foundation
import Combine

enum AuthState {
    case pending, loggedIn, loggedOut
}

protocol AuthProviderService {
    static var shared: AuthProviderService { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    func login(email: String, password: String) async throws
    func createAccount(for username: String, email: String, password: String) async throws
    func autoLogin() async
    func logout() async throws
}

final class AuthProviderServiceImp: AuthProviderService {
    
    static let shared: AuthProviderService = AuthProviderServiceImp()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    private init() { }
    
    func login(email: String, password: String) async throws {
        
    }
    
    func createAccount(for username: String, email: String, password: String) async throws {
        try await FirebaseManager.createAccount(for: username, email: email, password: password)
    }
    
    func autoLogin() async {
        
    }
    
    func logout() async throws {
        
    }
    
    
}

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
}
