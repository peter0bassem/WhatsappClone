//
//  BubbleImageView.swift
//  Whatsapp
//
//  Created by iCommunity app on 21/08/2024.
//

import SwiftUI

struct BubbleImageView: View {
    let item: MessageItem
    var body: some View {
        HStack {
            if item.direction == .sent { Spacer() }
            HStack {
                if item.direction == .sent { shareButton() }
                
                messageTextView()
                    .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
                    .frame(width: UIScreen.main.bounds.width * 0.70, alignment: .leading)
                    .background(item.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .applyTail(direction: item.direction)
                    .overlay {
                        if item.type == .video { playButton() }
                    }
                
                if item.direction == .received { shareButton() }
            }
            if item.direction == .received { Spacer() }
        }
    }
    
    private func messageTextView() -> some View {
        VStack(alignment: item.horizontalAlignment, spacing: -15) { // spacing between text and time
            
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
                        if item.text.isEmpty {
                            timestampView()
                        }
                    }
                    .onTapGesture {
                        
                    }
                if !item.text.isEmpty {
                    Text(item.text)
                        .padding([.horizontal, .bottom], 8)
                        .frame(maxWidth: .infinity, alignment: item.alignment)
                }
            }
            if !item.text.isEmpty {
                timestampView()
            }
        }
    }
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> Color in
            let imageSize = geometry.size
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
                .font(.caption2/*.system(size: 13)*/)
                .foregroundStyle(item.text.isEmpty ? .white : .gray)
                .fontWeight(item.text.isEmpty ? .heavy : .regular)
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
        VStack {
            BubbleImageView(item: .sentPlaceholder)
            BubbleImageView(item: .receivedPlaceholder)
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}

