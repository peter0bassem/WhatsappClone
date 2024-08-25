//
//  ChatPartnerPickerScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

enum ChatPartnerPickerOptions: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunity = "New Community"
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        return rawValue
    }
    
    var imageName: String {
        switch self {
        case .newGroup:
            return "person.2.fill"
        case .newContact:
            return "person.fill.badge.plus"
        case .newCommunity:
            return "person.3.fill"
        }
    }
}

struct ChatPartnerPickerScreen: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismsiss
    @StateObject private var chatPartnerPickerViewModel = ChatPartnerPickerViewModel()
    var onCreate: (_ channel: Channel) -> Void
    var body: some View {
        NavigationStack(path: $chatPartnerPickerViewModel.navStack) {
            List {
                ForEach(ChatPartnerPickerOptions.allCases) { item in
                    HeaderItemView(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard item == ChatPartnerPickerOptions.newGroup else { return }
                            chatPartnerPickerViewModel.navStack.append(.groupParnterPicker)
                        }
                }
                
                Section {
                    ForEach(chatPartnerPickerViewModel.users) { user in
                        ChatPartnerRowView(user: user)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    if let newChannel = await chatPartnerPickerViewModel.createDirectChannel(withPartner: user) {
                                        onCreate(newChannel)
                                    }
                                }
                            }
                            .task {
                                if chatPartnerPickerViewModel.hasReachedEnd(of: user) && !chatPartnerPickerViewModel.isFetching {
                                    await chatPartnerPickerViewModel.fetchUsers()
                                }
                            }
                    }
                } header: {
                    Text("Contacts on WhatsApp")
                        .textCase(nil)
                }
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                if chatPartnerPickerViewModel.isFetching {
                    ProgressView()
                        .controlSize(.regular)
                }
            }
            .navigationTitle("New Chats")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search name or number")
            .toolbar {
                createTrailingNavBarItem()
            }
            .navigationDestination(for: ChannelCreationRoute.self) { route in
                destinationView(for: route)
            }
            .onAppear {
                chatPartnerPickerViewModel.deselectAllChatPartners()
            }
            .alert(isPresented: $chatPartnerPickerViewModel.errorState.showError) {
                Alert(title: Text("Uh Oh😕"), message: Text(chatPartnerPickerViewModel.errorState.errorMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
    
    @ToolbarContentBuilder
    private func createTrailingNavBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                dismsiss()
            }, label: {
                Image(systemName: "xmark")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            })
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .groupParnterPicker:
            GroupPartnerPickerScreen(chatPartnerPickerViewModel: chatPartnerPickerViewModel)
        case .setupGroupChat:
            GroupSetupScreen(chatPartnerPickerViewModel: chatPartnerPickerViewModel, onCreate: onCreate)
        }
    }
}

extension ChatPartnerPickerScreen {
    private struct HeaderItemView: View {
        let item: ChatPartnerPickerOptions
        var body: some View {
            HStack {
                Image(systemName: item.imageName)
                    .font(.footnote)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                
                Text(item.title)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatPartnerPickerScreen { _ in }
}
