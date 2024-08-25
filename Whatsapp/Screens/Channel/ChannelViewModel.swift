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
    
    func onNewChannelCreation(_ channel: Channel) {
        showChartPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }
}
