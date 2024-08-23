//
//  RootScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    static func dummyUserViewModel() -> UserViewModel {
        let userViewModel = UserViewModel()
        userViewModel.user = .init(uid: "1", username: "Username", email: "username@gmail.com")
        return userViewModel
    }
}

struct RootScreen: View {
    @StateObject private var rootViewModel = RootViewModel()
    var body: some View {
        switch rootViewModel.authState {
        case .pending:
            ProgressView()
                .controlSize(.large)
        case .loggedIn(let userViewModel):
            MainTabView()
                .environmentObject(userViewModel)
        case .loggedOut:
            LoginScreen()
        }
    }
}

#Preview {
    RootScreen()
}
