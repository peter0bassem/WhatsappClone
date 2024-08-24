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
    func getCurrentUserId() -> String?
    func logout() async throws
}

final actor AuthProviderServiceImp: AuthProviderService {
    
    static let testAccounts: [String] = [
        "test7@gmail.com",
        "test8@gmail.com",
        "test9@gmail.com",
        "test10@gmail.com",
        "test11@gmail.com",
        "test12@gmail.com",
        "test13@gmail.com",
        "test14@gmail.com",
        "test15@gmail.com",
        "test16@gmail.com",
        "test17@gmail.com",
        "test18@gmail.com",
        "test19@gmail.com",
        "test20@gmail.com",
        "test20@gmail.com",
        "test21@gmail.com",
        "test22@gmail.com",
        "test23@gmail.com",
        "test24@gmail.com",
        "test25@gmail.com",
        "test26@gmail.com",
        "test27@gmail.com",
        "test28@gmail.com",
        "test29@gmail.com",
        "test30@gmail.com",
        "test31@gmail.com",
        "test32@gmail.com",
        "test33@gmail.com",
        "test34@gmail.com",
        "test35@gmail.com",
        "test36@gmail.com",
        "test37@gmail.com",
        "test38@gmail.com",
        "test39@gmail.com",
        "test40@gmail.com",
        "test41@gmail.com",
        "test42@gmail.com",
        "test43@gmail.com",
        "test44@gmail.com",
        "test45@gmail.com",
        "test46@gmail.com",
        "test47@gmail.com",
        "test48@gmail.com",
        "test49@gmail.com",
        "test50@gmail.com",
    ]
    
    static let shared: AuthProviderService = AuthProviderServiceImp()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    private init() { 
        Task {
            await autoLogin()
        }
    }
    
    func login(loginRequest: LoginRequest) async throws {
        if let user = try await AuthFirebaseManager.loginUser(loginRequest: loginRequest) {
            let userViewModel = UserViewModel()
            userViewModel.user = user
            self.authState.send(.loggedIn(userViewModel: userViewModel))
        } else {
            self.authState.send(.loggedOut)
        }
    }
    
    func createAccount(for username: String, email: String, password: String) async throws {
        guard let user = try await AuthFirebaseManager.createAccount(for: username, email: email, password: password) else { return }
        let userViewModel = UserViewModel()
        userViewModel.user = user
        self.authState.send(.loggedIn(userViewModel: userViewModel))
    }
    
    func autoLogin() async {
        if await !AuthFirebaseManager.checkUserLoggedIn() {
            self.authState.send(.loggedOut)
        } else {
            if let loggedInUser = await AuthFirebaseManager.fetchCurrentUserInfo() {
                let userViewModel = UserViewModel()
                userViewModel.user = loggedInUser
                self.authState.send(.loggedIn(userViewModel: userViewModel))
            } else {
                self.authState.send(.loggedOut)
            }
        }
    }
    
    func getCurrentUserId() -> String? {
        AuthFirebaseManager.getCurrentUserId()
    }
    
    func logout() async throws {
        try await AuthFirebaseManager.logoutUser()
        self.authState.send(.loggedOut)
    }
}
