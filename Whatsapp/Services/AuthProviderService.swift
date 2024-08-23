//
//  AuthProviderService.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import Foundation
import Combine

enum AuthState {
    case pending, loggedIn(userViewModel: UserViewModel), loggedOut
}

protocol AuthProviderService: Actor {
    static var shared: AuthProviderService { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    func login(loginRequest: LoginRequest) async throws
    func createAccount(for username: String, email: String, password: String) async throws
    func autoLogin() async
    func logout() async throws
}

final actor AuthProviderServiceImp: AuthProviderService {
    
    static let shared: AuthProviderService = AuthProviderServiceImp()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    private init() { 
        Task {
            await autoLogin()
        }
    }
    
    func login(loginRequest: LoginRequest) async throws {
        if let user = try await FirebaseManager.loginUser(loginRequest: loginRequest) {
            let userViewModel = UserViewModel()
            userViewModel.user = user
            self.authState.send(.loggedIn(userViewModel: userViewModel))
        } else {
            self.authState.send(.loggedOut)
        }
    }
    
    func createAccount(for username: String, email: String, password: String) async throws {
        guard let user = try await FirebaseManager.createAccount(for: username, email: email, password: password) else { return }
        let userViewModel = UserViewModel()
        userViewModel.user = user
        self.authState.send(.loggedIn(userViewModel: userViewModel))
    }
    
    func autoLogin() async {
        if await !FirebaseManager.checkUserLoggedIn() {
            self.authState.send(.loggedOut)
        } else {
            if let loggedInUser = await FirebaseManager.fetchCurrentUserInfo() {
                let userViewModel = UserViewModel()
                userViewModel.user = loggedInUser
                self.authState.send(.loggedIn(userViewModel: userViewModel))
            } else {
                self.authState.send(.loggedOut)
            }
        }
    }
    
    func logout() async throws {
        try await FirebaseManager.logoutUser()
        self.authState.send(.loggedOut)
    }
}
