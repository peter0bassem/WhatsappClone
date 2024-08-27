//
//  ChannelTabScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct ChannelTabScreen: View {
    
    @ObservedObject private var channelViewModel = ChannelViewModel()
    var body: some View {
        NavigationStack {
            List {
                archivedButton()
                
                ForEach(channelViewModel.channels) { channel in
                    NavigationLink {
                        ChatRoomScreen(channel: channel)
                    } label: {
                        ChannelItemView(channel: channel)
                    }
                }
                inboxFooterView()
                    .listRowSeparator(.hidden)
            }
            .safeAreaInset(edge: .top, content: {
                Color.clear
                    .frame(height: 0)
                    .background(.bar)
                    .border(.black)
            })
            .navigationTitle("Chats")
            .searchable(text: $channelViewModel.searchText)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .toolbar {
                leadingNavItems()
                trailingNavItems()
            }
            .sheet(isPresented: $channelViewModel.showChartPartnerPickerView) {
                ChatPartnerPickerScreen(onCreate: channelViewModel.onNewChannelCreation)
            }
            .navigationDestination(isPresented: $channelViewModel.navigateToChatRoom) {
                if let newChannel = channelViewModel.newChannel {
                    ChatRoomScreen(channel: newChannel)
                }
            }
            .task {
                await channelViewModel.fetchCurrentUserChannels()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    
                } label: {
                    Label("Select Chats", systemImage: "checkmark.circle")
                }

            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItems() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            aiButton()
            cameraButton()
            newChatButton()
        }
    }
    
    private func aiButton() -> some View {
        Button {
            
        } label: {
            Image(.circle)
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera")
        }
    }
    
    private func newChatButton() -> some View {
        Button {
            channelViewModel.showChartPartnerPickerView.toggle()
        } label: {
            Image(.plus)
        }
    }
    
    private func archivedButton() -> some View {
        Button {
            
        } label: {
            Label("Archived", systemImage: "archivebox.fill")
                .bold()
                .padding()
                .foregroundStyle(.gray)
        }
    }
    
    private func inboxFooterView() -> some View {
        HStack(alignment: .center) {
            Image(systemName: "lock")
            
            (
                Text("Your personal messages are")
                +
                Text(" ")
                +
                Text("end-to-end encrypted")
                    .foregroundStyle(.blue)
            )
        }
        .foregroundStyle(.gray)
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ChannelTabScreen()
}
