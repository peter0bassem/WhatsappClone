//
//  RootViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {
    @Published private(set) var authState: AuthState = .pending
    
    private var cancellable: AnyCancellable?
    
    init() {
        Task {
            cancellable = await AuthProviderServiceImp.shared.authState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] authState in
                    self?.authState = authState
                }
        }
    }
}
