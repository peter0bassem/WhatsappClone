//
//  ChatRoomScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI
import PhotosUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        
        willShow
            .merge(with: willHide)
            .sink { [weak self] notification in
                guard let self = self else { return }
                self.handleKeyboard(notification: notification)
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        
        isKeyboardVisible = isShowing
        
        if isShowing, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
        } else {
            keyboardHeight = 0
        }
    }
}

struct ChatRoomScreen: View {
    let channel: Channel
    @State private var channelName: String = ""
    @StateObject private var chatViewModel: ChatViewModel
    @State private var hideToolbar: Bool = false
    @State private var circleProfileImageView = CircleProfileImageView(profileImageUrl: nil, size: .medium)
    
    @StateObject private var keyboardObserver = KeyboardObserver()
    @StateObject private var voiceMessagePlayer = VoiceMessagePlayer()
    
    init(channel: Channel) {
        self.channel = channel
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(channel: channel))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
//                    ForEach(chatViewModel.messages) { messageItem in
                    ForEach(Array(chatViewModel.messages.enumerated()), id: \.element.id) { index, messageItem in
                        BubbleView(message: messageItem, channel: channel, isNewDay: chatViewModel.isMessageNewDay(for: messageItem, atIndex: index))
                            .id(messageItem)
                            .environmentObject(chatViewModel)
                            .environmentObject(voiceMessagePlayer)
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
            .onChange(of: chatViewModel.messages) { _ in
                scrollToLastMessage(proxy: proxy)
            }
            .onChange(of: keyboardObserver.isKeyboardVisible) { _ in
                scrollToLastMessage(proxy: proxy)
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged{ _ in
                        UIApplication.dismissKeyboard()
                    }
            )
            .refreshable(action: {
                print("Should refresh data")
            })
            .fullScreenCover(isPresented: $chatViewModel.videoPlayerState.show) {
                if let player = chatViewModel.videoPlayerState.player {
                    MediaPlayerView(player: player ) {
                        chatViewModel.dismissMediaPlayer()
                    }
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
                .environmentObject(chatViewModel)
        }
        .animation(.easeInOut, value: chatViewModel.showPhotoPickerPreview)
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if let lastMessage = chatViewModel.messages.last {
                withAnimation {
                    proxy.scrollTo(lastMessage, anchor: .bottom)
                }
            }
        }
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
