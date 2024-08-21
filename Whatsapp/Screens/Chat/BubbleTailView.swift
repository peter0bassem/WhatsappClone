//
//  BubbleTailView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct BubbleTailView: View {
    var messageDirection: MessageDirection
    private var backgroundColor: Color {
        messageDirection == .received ? .bubbleWhite : .bubbleGreen
    }
    var body: some View {
        Image(messageDirection == .sent ? .outgoingTail : .incomingTail)
            .renderingMode(.template)
            .resizable()
            .frame(width: 10, height: 10)
            .offset(y: 3)
            .foregroundStyle(backgroundColor)
            
    }
}

#Preview {
    ScrollView {
        BubbleTailView(messageDirection: .sent)
        BubbleTailView(messageDirection: .received)
    }
    .frame(maxWidth: .infinity)
    .background(Color.red.opacity(0.1))
}
