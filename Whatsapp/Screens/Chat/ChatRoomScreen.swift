//
//  ChatRoomScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI
import PhotosUI

struct ChatRoomScreen: View {
    let channel: Channel
    @State private var channelName: String = ""
    @StateObject private var chatViewModel: ChatViewModel
    @State private var hideToolbar: Bool = false
    @State private var circleProfileImageView = CircleProfileImageView(profileImageUrl: nil, size: .medium)
    
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
        )
        .toolbar {
            leadingNavItems()
            trailingNavItems()
        }
        .scrollIndicators(.hidden)
        .photosPicker(isPresented: $chatViewModel.showPhotoPicker, selection: $chatViewModel.photoPickerItems, maxSelectionCount: 6, photoLibrary: .shared()) //photoLibrary is added for item deletion from picker.
        .safeAreaInset(edge: .bottom) {
            bottomSafeAreaView()
                .background(.whatsAppWhite)
        }
        .toolbar(hideToolbar ? .hidden : .visible, for: .tabBar)
        .task {
            circleProfileImageView = await CircleProfileImageView(channel: channel, size: .mini)
        }
        .onAppear {
            hideToolbar = true
        }
        .onDisappear {
            hideToolbar = false
        }
        .fullScreenCover(isPresented: $chatViewModel.videoPlayerState.show) {
            if let player = chatViewModel.videoPlayerState.player {
                MediaPlayerView(player: player ) {
                    chatViewModel.dismissMediaPlayer()
                }
            }
        }
    }
    
    private func bottomSafeAreaView() -> some View {
        VStack(spacing: 0) {
            if chatViewModel.showPhotoPickerPreview {
                MediaAttachmentPreviewView(attachments: chatViewModel.selectedAttachments, actionObserver: chatViewModel.actionObserver)
                    .transition(.move(edge: .bottom))
                Divider()
            }
            TextInputAreaView(messageText: $chatViewModel.messageText, isRecording: $chatViewModel.isRecordingVoiceMessage, elapsedTime: $chatViewModel.elapsedVoiceMessageTime, actionObserver: chatViewModel.actionObserver)
        }
        .animation(.easeInOut, value: chatViewModel.showPhotoPickerPreview)
    }
}

private extension ChatRoomScreen {
    private var channelTitle: String {
        let maxChar = 20
        let trailingChars = channelName.count > maxChar ? "..." : ""
        return String(channelName.prefix(maxChar) + trailingChars)
    }
    
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                circleProfileImageView
                VStack(alignment: .leading) {
                    Text(channelTitle)
                        .bold()
                        .task {
                            channelName = await channel.title
                        }
//                    Text("Online")
//                        .font(.system(size: 12))
//                        .foregroundStyle(.gray)
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
