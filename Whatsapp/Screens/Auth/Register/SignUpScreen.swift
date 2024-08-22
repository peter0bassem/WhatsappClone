//
//  SignUpScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI

struct SignUpScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Spacer()
            AuthHeaderView()
            AuthTextField(type: .email, text: $authViewModel.email)
            AuthTextField(type: .custom("at", "Username", keyboardType: .default, autoCapitalization: .never), text: $authViewModel.username)
            AuthTextField(type: .password, text: $authViewModel.password)
            AuthButton(title: "Create an Account") {
                Task {
                    await authViewModel.performSignup()
                }
            }
            .disabled(authViewModel.disableSignUpButton)
            Spacer()
            backButton()
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [.green, .green.opacity(0.8), .teal], startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
    
    private func backButton() -> some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                (
                    Text("Already have an account?")
                    +
                    Text(" ")
                    +
                    Text("Login")
                        .bold()
                )
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SignUpScreen(authViewModel: AuthViewModel())
}
