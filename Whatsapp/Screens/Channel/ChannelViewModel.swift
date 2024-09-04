//
//  ChannelViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation
import Combine

enum ChannelTabRoutes: Hashable {
    case chatRoont(channel: Channel)
}

final class ChannelViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var navRoutes: [ChannelTabRoutes] = []
    @Published var showChartPartnerPickerView = false
    @Published var navigateToChatRoom = false
    @Published var newChannel: Channel?
    @Published var channels: [Channel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func onNewChannelCreation(_ channel: Channel) {
        showChartPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }
    
    @MainActor
    func fetchCurrentUserChannels() async {
        guard let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId() else { return }
        await MessageServiceImpl.shared.fetchUserChannels(withUserId: currentUid)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished observing channels.")
                case .failure(let error):
                    print("Failed to observe channels: \(error)")
                }
            }, receiveValue: { [weak self] channels in
                self?.channels = channels.sorted(by: { ($0.lastMessageTimestamp ?? 0.0) > ($1.lastMessageTimestamp ?? 0.0) })
            })
            .store(in: &cancellables)
        
        
//        do {
//            let channels = try await MessageServiceImpl.shared.fetchUserChannels(withUserId: currentUid)
//            self.channels = channels.sorted(by: { $0.lastMessageTimestamp > $1.lastMessageTimestamp })
//        } catch {
//            print("Failed to fetch user channels: \(error)")
//        }
    }
}
