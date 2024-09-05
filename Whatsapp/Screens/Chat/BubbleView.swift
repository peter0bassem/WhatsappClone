//
//  BubbleView.swift
//  Whatsapp
//
//  Created by iCommunity app on 05/09/2024.
//

import SwiftUI

struct BubbleView: View {
    let message: Message
    let channel: Channel
    let isNewDay: Bool
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isNewDay {
                newDayTimeStampTextView()
                    .padding(.vertical, 16)
            }
            composeDynamicBubbleView()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func composeDynamicBubbleView() -> some View {
        switch message.type {
        case .text:
            BubbleTextView(item: message)
                .environmentObject(voiceMessagePlayer)
        case .photo, .video:
            BubbleImageView(item: message, chatActionObserver: chatViewModel.chatActionObserver)
                .environmentObject(voiceMessagePlayer)
        case .audio:
            BubbleAudioView(item: message, chatActionObserver: chatViewModel.chatActionObserver)
                .environmentObject(voiceMessagePlayer)
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                newDayTimeStampTextView()
                    .padding(.vertical, 16)
                ChannelCreationTextView()
                    .padding(.bottom, 5)
                    .environmentObject(voiceMessagePlayer)
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                        .padding(.bottom, 5)
                        .environmentObject(voiceMessagePlayer)
                }
            default:
                Text("UNKNOWN")
            }
        default: EmptyView()
        }
    }
    
    private func newDayTimeStampTextView() -> some View {
        Text((message.timestamp ?? 0.0).toDate().relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal)
            .background(.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    BubbleView(message: .receivedPlaceholder, channel: .placeholderChannel, isNewDay: false)
//        .background(Color.gray.opacity(0.2))
        .environmentObject(ChatViewModel(channel: .placeholderChannel))
        .environmentObject(VoiceMessagePlayer())
}
