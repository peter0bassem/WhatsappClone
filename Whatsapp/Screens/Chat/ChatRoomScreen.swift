//
//  ChatRoomScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI
import Combine
import SwiftUIIntrospect

struct ChatRoomScreen: View {
    let channel: Channel
    @State private var channelName: String = ""
    @StateObject private var chatViewModel: ChatViewModel
    @State private var hideToolbar: Bool = false
    
    init(channel: Channel) {
        self.channel = channel
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(channel: channel))
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(chatViewModel.messages) { messageItem in
                    switch messageItem.type {
                    case .text/*(_)*/:
                        BubbleTextView(item: messageItem)
                    case .photo, .video:
                        BubbleImageView(item: messageItem)
                    case .audio:
                        BubbleAudioView(item: messageItem)
                    case .admin(let adminType):
                        switch adminType {
                        case .channelCreation:
                            ChannelCreationTextView()
                                .padding(.bottom, 5)
                            if channel.isGroupChat {
                                AdminMessageTextView(channel: channel)
                                    .padding(.bottom, 5)
                            }
                        default:
                            Text("UNKNOWN")
                        }
                    default: EmptyView()
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, 10)
        .safeAreaInset(edge: .top, content: {
            Color.clear
                .frame(height: 0)
                .background(.bar)
                .border(.black)
        })
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Image(.chatbackground)
                .resizable()
                .scaledToFill()
//                .ignoresSafeArea(edges: [.leading, .bottom, .trailing])
        )
        .toolbar {
            leadingNavItems()
            trailingNavItems()
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            TextInputAreaView(messageText: $chatViewModel.messageText, sendMessageSingleObserver: chatViewModel.sendMessageSingleObserver)
        }
        .toolbar(hideToolbar ? .hidden : .visible, for: .tabBar)
        .onAppear {
            hideToolbar = true
        }
        .onDisappear {
            hideToolbar = false
        }
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
