//
//  ChatPartnerRowView.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

struct ChatPartnerRowView<Content: View>: View {
    let user: User
    private let trailingItems: Content
    
    init(user: User, @ViewBuilder trailingItems: () -> Content = { EmptyView() }) {
        self.user = user
        self.trailingItems = trailingItems()
    }
    
    var body: some View {
        HStack {
            CircleProfileImageView(profileImageUrl: user.profileImageUrl, size: .xSmall)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(user.username)
                    .bold()
                    .foregroundStyle(.whatsAppBlack)
                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            trailingItems
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholderUser)
}
