//
//  LoginScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI

struct LoginScreen: View {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                AuthHeaderView()
                AuthTextField(type: .email, text: $authViewModel.email)
                AuthTextField(type: .password, text: $authViewModel.password)
                forgotPasswordButton()
                AuthButton(title: "Login") {
                    let _ = print("Perform login...")
                }
                .disabled(authViewModel.disableLoginButton)
                Spacer()
                signUpButton()
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.teal.gradient)
            .ignoresSafeArea()
        }
    }
    
    private func forgotPasswordButton() -> some View {
        Button {
            
        } label: {
            Text("Forgrot Password?")
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 16)
        .bold()
        .padding(.vertical, 8)
    }
    
    private func signUpButton() -> some View {
        NavigationLink {
            SignUpScreen(authViewModel: authViewModel)
        } label: {
            HStack {
                Image(systemName: "sparkles")
                (
                    Text("Don't have an account?")
                    +
                    Text(" ")
                    +
                    Text("Create One")
                        .bold()
                )
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    LoginScreen()
}
