//
//  ChatRoomScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct ChatRoomScreen: View {
    let channel: Channel
    @State private var channelName: String = ""
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Message.stubMessages) { messageItem in
                    switch messageItem.type {
                    case .text(_):
                        BubbleTextView(item: messageItem)
                    case .photo, .video:
                        BubbleImageView(item: messageItem)
                    case .audio:
                        BubbleAudioView(item: messageItem)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, 10)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.gray.opacity(0.1))
        .toolbar {
            leadingNavItems()
            trailingNavItems()
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            TextInputAreaView()
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

private extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Circle()
                    .frame(width: 35, height: 35)
                VStack(alignment: .leading) {
                    Text(channelName)
                        .bold()
                        .task {
                            channelName = await channel.title
                        }
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItems() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "video")
            })
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "phone")
            })
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen(channel: .placeholderChannel)
    }
}
