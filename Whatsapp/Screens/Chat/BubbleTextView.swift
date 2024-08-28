//
//  BubbleTextView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct BubbleTextView: View {
    let item: Message
    @State private var itemDirection: MessageDirection = .unset
    @State private var itemHorizontalAlignmnet: HorizontalAlignment = .center
    @State private var itemAlignment: Alignment = .center
    @State private var itemBackground: Color = .clear
    @State private var showGroupPartnerInfo: Bool = false
    var body: some View {
        HStack {
            if itemDirection == .sent {  Spacer(minLength: UIScreen.main.bounds.width * 0.30) }
            
            HStack(alignment: .bottom, spacing: 5) {
                if showGroupPartnerInfo {
                    CircleProfileImageView(profileImageUrl: item.sender?.profileImageUrl, size: .mini)
                        .offset(y: 5)
                }
                VStack(alignment: itemHorizontalAlignmnet, spacing: -20) {
                    Text(item.text.removeOptional)
                        .padding(10)
                    
                    timestampView()
                }
                .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
                .fixedSize(horizontal: false, vertical: true)
                .background(itemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .applyTail(direction: itemDirection)
            }
            
            if itemDirection == .received { Spacer(minLength: UIScreen.main.bounds.width * 0.30) }
        }
        .task {
            itemDirection = await item.direction
            itemHorizontalAlignmnet = await item.horizontalAlignment
            itemAlignment = await item.alignment
            itemBackground = await item.backgroundColor
            showGroupPartnerInfo = await item.showGroupPartnerInfo
        }
    }
    
    private func timestampView() -> some View {
        HStack(spacing: 2) {
            Text((item.timestamp ?? 0.0).toDate().formatToTime)
                .font(.footnote)
                .foregroundStyle(.gray)
            
            if !showGroupPartnerInfo {
                if itemDirection == .sent {
                    Image(.seen)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color(.systemBlue))
                }
            }
        }
        .padding(10)
    }
}

#Preview {
    ScrollView {
        VStack {
            BubbleTextView(item: .sentPlaceholder)
            BubbleTextView(item: .receivedPlaceholder)
            BubbleTextView(item: .sentPlaceholder)
            BubbleTextView(item: .init(id: "", isGroupChat: true, text: "Hello there!", type: .text, ownerId: "RfZDo1E35IVnZUH4C14pEgr7wxH2", timestamp: nil))
            BubbleTextView(item: .init(id: "", isGroupChat: true, text: "Hi!", type: .text, ownerId: "", timestamp: nil))
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}
