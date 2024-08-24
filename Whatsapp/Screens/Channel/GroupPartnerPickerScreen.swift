//
//  GroupPartnerPickerScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

struct GroupPartnerPickerScreen: View {
    @State private var searchText: String = ""
    @ObservedObject var chatPartnerPickerViewModel: ChatPartnerPickerViewModel
    var body: some View {
        List {
            if chatPartnerPickerViewModel.showSelectedUsers {
                SelectedChatPartnerView(users: $chatPartnerPickerViewModel.selectedChatPartners) { user in
                    chatPartnerPickerViewModel.handleItemSelection(user)
                }
//                .animation(.easeInOut, value: chatPartnerPickerViewModel.selectedChatPartners)
            }
            
            Section {
                ForEach(chatPartnerPickerViewModel.users) { item in
                    chatPartnerRowView(item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            chatPartnerPickerViewModel.handleItemSelection(item)
                        }
                        .task {
                            if chatPartnerPickerViewModel.hasReachedEnd(of: item) && !chatPartnerPickerViewModel.isFetching {
                                await chatPartnerPickerViewModel.fetchUsers()
                            }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottom) {
            if chatPartnerPickerViewModel.isFetching {
                ProgressView()
                    .controlSize(.regular)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search name or number")
        .animation(.easeInOut, value: chatPartnerPickerViewModel.showSelectedUsers)
        .toolbar {
            titleView()
            trailingNavBarItem()
        }
    }
    
    private func chatPartnerRowView(_ user: User) -> some View {
        ChatPartnerRowView(user: user) {
            Spacer()
            let isUserSelected = chatPartnerPickerViewModel.isUserSelected(user)
            Image(systemName: isUserSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isUserSelected ? .blue : Color(.systemGray4))
                .imageScale(.large)
        }
    }
}

extension GroupPartnerPickerScreen {
    @ToolbarContentBuilder
    private func titleView() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add Participants")
                    .bold()
                
                let counts = chatPartnerPickerViewModel.selectedChatPartners.count
                let maxCount = ChannelConstants.maxGroupParticipants
                Text("\(counts)/\(maxCount)")
                    .foregroundStyle(.gray)
                    .font(.footnote)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                chatPartnerPickerViewModel.navStack.append(.setupGroupChat)
            }, label: {
                Text("Next")
                    .bold()
            })
            .disabled(chatPartnerPickerViewModel.disableNextButton)
        }
    }
    
    private func loadMoreUsers() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await chatPartnerPickerViewModel.fetchUsers()
            }
    }
}

#Preview {
    NavigationStack {
        GroupPartnerPickerScreen(chatPartnerPickerViewModel: .init())
    }
}
