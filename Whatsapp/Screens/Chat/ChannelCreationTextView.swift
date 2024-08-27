//
//  ChannelCreationTextView.swift
//  Whatsapp
//
//  Created by iCommunity app on 27/08/2024.
//

import SwiftUI

struct ChannelCreationTextView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    private var backgroundColor: Color {
        return colorScheme == .dark ? Color.black : Color.yellow
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            (
                Text(Image(systemName: "lock.fill"))
                +
                Text("Messages and Calls are end-to-end encrypted, No one outside this chat, even WhatsApp can read or listen to them.")
                +
                Text(" Learn more.")
                    .bold()
            )
        }
        .font(.footnote)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 30)
    }
}

#Preview {
    ChannelCreationTextView()
}
