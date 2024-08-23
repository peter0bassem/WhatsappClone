//
//  SettingsViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    func logutUser() {
        Task {
            do {
                try await AuthProviderServiceImp.shared.logout()
            } catch {
                print(error)
            }
        }
    }
}
