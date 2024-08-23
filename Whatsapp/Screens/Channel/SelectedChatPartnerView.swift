//
//  SelectedChatPartnerView.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import SwiftUI

struct SelectedChatPartnerView: View {
    @Binding var users: [User]
    var cancelButtonClickAction: (_ user: User) -> ()
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(users) { item in
                    chatPartnerItemView(item)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private func chatPartnerItemView(_ user: User) -> some View {
        VStack {
            Circle()
                .fill(Color.gray)
                .frame(width: 60, height: 60)
                .overlay(alignment: .topTrailing) {
                    cancelButton(for: user)
                }
            Text(user.username)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
        }
    }
    
    private func cancelButton(for user: User) -> some View {
        Button {
            cancelButtonClickAction(user)
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(5)
                .background(Color(.systemGray2))
                .clipShape(Circle())
        }

    }
}

#Preview {
    SelectedChatPartnerView(users: .constant(User.placeholders)) { _ in }
}
