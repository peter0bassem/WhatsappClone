//
//  ChannelItemView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: Channel
    @State private var channelTitle: String = ""
    @State private var circleProfileImageView: CircleProfileImageView = CircleProfileImageView(profileImageUrl: nil, size: .small)
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            circleProfileImageView
            
            VStack(alignment: .leading, spacing: 3) {
                titleView()
                lastMessagePreview()
            }
        }
        .task {
            circleProfileImageView = await CircleProfileImageView(channel: channel, size: .medium)
        }
    }
    
    private func titleView() -> some View {
        HStack {
            Text(channelTitle)
                .lineLimit(1)
                .bold()
                .task {
                    channelTitle = await channel.title
                }
            
            Spacer()
            
            Text((channel.lastMessageTimestamp ?? 0.0).toDate().dateOrTimeRepresentation)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text(channel.lastMessage.removeOptional)
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView(channel: .placeholderChannel)
}
