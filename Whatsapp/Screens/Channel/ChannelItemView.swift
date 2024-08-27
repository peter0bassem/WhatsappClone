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
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 3) {
                titleView()
                lastMessagePreview()
            }
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
            
            Text("5:50 pm")
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text(channel.lastMessage)
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView(channel: .placeholderChannel)
}
