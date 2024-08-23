//
//  SettingsTabScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct SettingsTabScreen: View {
    
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView()
                
                Section {
                    SettingsItemView(item: .broadCastLists)
                    SettingsItemView(item: .starredMessages)
                    SettingsItemView(item: .linkedDevices)
                }
                
                Section {
                    SettingsItemView(item: .account)
                    SettingsItemView(item: .privacy)
                    SettingsItemView(item: .chats)
                    SettingsItemView(item: .notifications)
                    SettingsItemView(item: .storage)
                }
                
                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $settingsViewModel.searchText)
            .scrollIndicators(.hidden)
            .toolbar {
                leadingNavBarItem()
                trailingNavBarItem()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func leadingNavBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: settingsViewModel.logutUser, label: {
                Text("Sign Out")
                    .foregroundStyle(.red)
            })
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Save")
                    .bold()
            })
        }
    }
}

private struct SettingsHeaderView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        Section {
            HStack {
                Circle()
                    .frame(width: 55, height: 55)
                userInfoTextView()
            }
            SettingsItemView(item: .avatar)
        }
    }
    
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(userViewModel.user?.username.capitalized ?? "")
                    .font(.title2)
                Spacer()
                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            Text("Hey there! I'm using WhatsApp.")
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabScreen()
        .environmentObject(UserViewModel.dummyUserViewModel())
}
