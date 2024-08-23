//
//  ChatPartnerRowView.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

struct ChatPartnerRowView: View {
    let user: User
    var body: some View {
        HStack {
            Circle()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(user.username)
                    .bold()
                    .foregroundStyle(.whatsAppBlack)
                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholderUser)
}
