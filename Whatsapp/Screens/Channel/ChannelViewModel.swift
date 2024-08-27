//
//  ChannelViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation

final class ChannelViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var showChartPartnerPickerView = false
    @Published var navigateToChatRoom = false
    @Published var newChannel: Channel?
    @Published var channels: [Channel] = []
    
    func onNewChannelCreation(_ channel: Channel) {
        showChartPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }
    
    @MainActor
    func fetchCurrentUserChannels() async {
        guard let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId() else { return }
        do {
            let channels = try await MessageServiceImpl.shared.fetchUserChannels(withUserId: currentUid)
            self.channels = channels.sorted(by: { $0.lastMessageTimestamp > $1.lastMessageTimestamp })
        } catch {
            print("Failed to fetch user channels: \(error)")
        }
    }
}
