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
    var body: some View {
        NavigationStack {
            List {
                ForEach(ChatPartnerPickerOptions.allCases) { item in
                    HeaderItemView(item: item)
                }
                
                Section {
                    ForEach(0..<12) { _ in
                        ChatPartnerRowView(user: .placeholderUser)
                    }
                } header: {
                    Text("Contacts on WhatsApp")
                        .textCase(nil)
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("New Chats")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search name or number")
            .toolbar {
                createTrailingNavBarItem()
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
}

extension ChatPartnerPickerScreen {
    private struct HeaderItemView: View {
        let item: ChatPartnerPickerOptions
        var body: some View {
            Button {
                
            } label: {
                HStack {
                    Image(systemName: item.imageName)
                        .font(.footnote)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                    
                    Text(item.title)
                }
            }
        }
    }
}

#Preview {
    ChatPartnerPickerScreen()
}
