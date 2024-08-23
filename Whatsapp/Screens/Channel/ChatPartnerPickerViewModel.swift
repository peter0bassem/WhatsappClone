//
//  ChatPartnerPickerViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation

enum ChannelCreationRoute {
    case groupParnterPicker
    case setupGroupChat
}

enum ChannelConstants {
    static let maxGroupParticipants = 12
}

final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack: [ChannelCreationRoute] = []
    @Published var selectedChatPartners: [User] = []
    
    var showSelectedUsers: Bool {
        return !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartners.isEmpty
    }
    
    func handleItemSelection(_ item: User) {
        if isUserSelected(item) {
            // deselect
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            // select
            selectedChatPartners.append(item)
        }
    }
    
    func isUserSelected(_ user: User) -> Bool {
        return selectedChatPartners.contains { $0.uid == user.uid }
    }
}
