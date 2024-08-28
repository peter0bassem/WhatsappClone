//
//  BubbleImageView.swift
//  Whatsapp
//
//  Created by iCommunity app on 21/08/2024.
//

import SwiftUI

struct BubbleImageView: View {
    let item: Message
    @State private var itemDirection: MessageDirection = .unset
    @State private var itemHorizontalAlignmnet: HorizontalAlignment = .center
    @State private var itemAlignment: Alignment = .center
    @State private var itemBackground: Color = .clear
    @State private var showGroupPartnerInfo: Bool = false
    var body: some View {
        HStack {
            if itemDirection == .sent { Spacer() }
            
            HStack() {
                if itemDirection == .sent { shareButton() }
                
                HStack(alignment: .bottom, spacing: 5) {
                    if itemDirection == .received {
                        if showGroupPartnerInfo {
                            CircleProfileImageView(profileImageUrl: item.sender?.profileImageUrl, size: .mini)
                                .offset(y: 5)
                        }
                    }
                    
                    imageAndMessageTextView()
                        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
                        .frame(width: UIScreen.main.bounds.width * 0.70, alignment: .leading)
                        .background(itemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .applyTail(direction: itemDirection)
                        .overlay {
                            if item.type == .video { playButton() }
                        }
                }
                
                if itemDirection == .received { shareButton() }
            }
            if itemDirection == .received { Spacer() }
        }
        .frame(maxWidth: .infinity, alignment: itemAlignment)
        .task {
            itemDirection = await item.direction
            itemHorizontalAlignmnet = await item.horizontalAlignment
            itemAlignment = await item.alignment
            itemBackground = await item.backgroundColor
            showGroupPartnerInfo = await item.showGroupPartnerInfo
        }
    }
    
    private func imageAndMessageTextView() -> some View {
        VStack(alignment: itemHorizontalAlignmnet, spacing: -15) { // spacing between text and time
            
            VStack(alignment: .leading, spacing: 0) { // image and text views
                Image(.stubImage0)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, -135)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .background(rectReader())
                    .padding(5)
                    .overlay(alignment: .bottomTrailing) {
                        if item.text.removeOptional.isEmptyOrWhiteSpace {
                            timestampView()
                        }
                    }
                    .onTapGesture {
                        
                    }
                if !item.text.removeOptional.isEmptyOrWhiteSpace {
                    Text(item.text.removeOptional)
                        .padding([.horizontal, .bottom], 8)
                        .frame(maxWidth: .infinity, alignment: itemAlignment)
                }
            }
            if !item.text.removeOptional.isEmptyOrWhiteSpace {
                timestampView()
            }
        }
    }
    
    private func rectReader() -> some View {
        return GeometryReader { _ -> Color in
            return .clear
        }
    }
    
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10 )
                .foregroundStyle(.white)
                .background(.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
            
        }
//        .padding(.horizontal, 0)

    }
    
    private func playButton() -> some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.gray)
            .background(.thinMaterial)
            .clipShape(Circle())
    }
    
    private func timestampView() -> some View {
        HStack(spacing: 2 ) {
            Text("3:05 PM")
                .font(.footnote/*.system(size: 13)*/)
                .foregroundStyle(item.text.removeOptional.isEmptyOrWhiteSpace ? .white : .gray)
                .fontWeight(item.text.removeOptional.isEmptyOrWhiteSpace ? .heavy : .regular)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            
            if itemDirection == .sent {
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
        VStack {
            BubbleImageView(item: .sentPlaceholder)
            BubbleImageView(item: .receivedPlaceholder)
            BubbleImageView(item: .init(id: "", isGroupChat: true, text: nil, type: .photo, ownerId: "", timestamp: nil))
            
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}

