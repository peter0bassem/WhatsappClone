//
//  BubbleTextView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct BubbleTextView: View {
    let item: MessageItem
    var body: some View {
        HStack {
            if item.direction == .sent {
                Spacer()
            }
            VStack(alignment: item.horizontalAlignment, spacing: -20) { // spacing between text and time
                Text(item.direction == .sent ? "Hi John, it's been so long since we last catch up, how are you doing?" : "Hey!! Wanna meet for a dinner tonight?")
                    .padding(10) // padding between text and edges
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                timestampView()
//                    .background(Color.yellow)
//                    .padding(.top, item.direction == .received ? -16 : 0)
//                    .padding(.top, item.direction == .sent ? -2 : 0)
            }
            .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
            .frame(width: UIScreen.main.bounds.width * 0.70, alignment: .leading)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .applyTail(direction: item.direction)
            
            if item.direction == .received {
                Spacer()
            }
        }
    }
    
    private func timestampView() -> some View {
        HStack(spacing: 3) {
            Text("3:05 PM")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(.systemBlue))
            }
        }
        .padding(10)
    }
}

#Preview {
    ScrollView {
        BubbleTextView(item: .sentPlaceholder)
        BubbleTextView(item: .receivedPlaceholder)
        BubbleTextView(item: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}
