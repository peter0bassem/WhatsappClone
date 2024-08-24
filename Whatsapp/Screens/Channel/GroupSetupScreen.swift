//
//  GroupSetupScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

struct GroupSetupScreen: View {
    @State private var channelName: String = ""
    @ObservedObject var chatPartnerPickerViewModel: ChatPartnerPickerViewModel
    var body: some View {
        List {
            Section {
                channelSetupHeaderView()
            }
            
            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }
            
            Section {
                SelectedChatPartnerView(users: $chatPartnerPickerViewModel.selectedChatPartners) { user in
                    chatPartnerPickerViewModel.handleItemSelection(user)
                }
            } header: {
                Text("Participants: \(chatPartnerPickerViewModel.selectedChatPartners.count) of \(ChannelConstants.maxGroupParticipants)")
                    .bold()
            }
            .listRowBackground(Color.clear)

        }
        .scrollIndicators(.hidden)
        .navigationTitle("New Group")
        .toolbar {
            trailingNavBarItem()
        }
    }
    
    private func channelSetupHeaderView() -> some View {
        HStack {
            profileImageView()
            TextField("", text: $channelName, prompt: Text("Group Name (Optional)"), axis: .vertical)
        }
    }
    
    private func profileImageView() -> some View {
        Button {
            
        } label: {
            ZStack {
                Image(systemName: "camera.fill")
                    .imageScale(.large)
            }
            .frame(width: 60, height: 60)
            .background(Color(.systemGray5))
            .clipShape(Circle())
        }

    }
    
    @ToolbarContentBuilder
    private func trailingNavBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Create")
                    .bold()
            })
            .disabled(chatPartnerPickerViewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        GroupSetupScreen(chatPartnerPickerViewModel: .init())
    }
}
