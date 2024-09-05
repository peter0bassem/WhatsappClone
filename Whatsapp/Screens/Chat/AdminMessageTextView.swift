//
//  AdminMessageTextView.swift
//  Whatsapp
//
//  Created by iCommunity app on 27/08/2024.
//

import SwiftUI

struct AdminMessageTextView: View {
    let channel: Channel
    @State private var isChannelCreatedByMe: Bool = false
    var body: some View {
        VStack {
            if isChannelCreatedByMe {
                textView("You created this group. Tap to add\n members")
            } else {
                textView("\(channel.creatorName) has created this group.")
                textView("\(channel.creatorName) add you.")
            }
        }
        .frame(maxWidth: .infinity)
        .task {
            isChannelCreatedByMe = await channel.isCreatedByMe
        }
    }
    
    private func textView(_ text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding(8)
            .padding(.horizontal, 5)
            .background(.bubbleWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
        
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        AdminMessageTextView(channel: .placeholderChannel)
    }
    .ignoresSafeArea()
}
