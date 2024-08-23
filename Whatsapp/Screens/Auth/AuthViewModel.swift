//
//  AuthViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "")

    var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    var disableSignUpButton: Bool {
        email.isEmpty || username.isEmpty || password.isEmpty || isLoading
    }
    
    func performLogin() async {
        isLoading = true
        do {
            let loginRequest = LoginRequest(email: email, password: password)
            try await AuthProviderServiceImp.shared.login(loginRequest: loginRequest)
        } catch {
            errorState = (true, "Failed to login user \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func performSignup() async {
        isLoading = true
        do {
            try await AuthProviderServiceImp.shared.createAccount(for: username, email: email, password: password)
        } catch  {
            errorState = (true, "Failed to create account \(error.localizedDescription)")
            isLoading = false
        }
    }
}
