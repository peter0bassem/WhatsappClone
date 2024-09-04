//
//  BubbleImageView.swift
//  Whatsapp
//
//  Created by iCommunity app on 21/08/2024.
//

import SwiftUI
import Kingfisher
import Combine

struct BubbleImageView: View {
    let item: Message
    var chatActionObserver: PassthroughSubject<MessageType, Never>
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
                        .background(itemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .applyTail(direction: itemDirection)
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
                KFImage(URL(string: item.thumbnailUrl.removeOptional))
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, -135)
                    .frame(width: item.imageSize.width, height: item.imageSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(5)
                    .overlay(alignment: .bottomTrailing) {
                        if item.text.removeOptional.isEmptyOrWhiteSpace {
                            timestampView()
                        }
                    }
                    .overlay {
                        if item.type == .video(videoURL: URL(string: item.videoUrl.removeOptional)) { playButton() }
                    }
                    .onTapGesture {
                        guard item.type == .photo else { return }
                        print("Image pressed for fullscreen")
                    }
                    
                if !item.text.removeOptional.isEmptyOrWhiteSpace {
                    Text(item.text.removeOptional)
                        .padding([.horizontal, .bottom], 8)
                        .frame(maxWidth: item.imageSize.width, alignment: .leading) //itemAlignment
                }
            }
            if !item.text.removeOptional.isEmptyOrWhiteSpace {
                timestampView()
                    .frame(width: item.imageSize.width)
            }
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
    }
    
    private func playButton() -> some View {
        Button {
            chatActionObserver.send(.video(videoURL: URL(string: item.videoUrl.removeOptional)))
        } label: {
            Image(systemName: "play.fill")
                .padding()
                .imageScale(.large)
                .foregroundStyle(.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }
    
    private func timestampView() -> some View {
        HStack(spacing: 2 ) {
            Text((item.timestamp ?? 0.0).toDate().formatToTime)
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
            BubbleImageView(item: .sentPlaceholder, chatActionObserver: .init())
            BubbleImageView(item: .receivedPlaceholder, chatActionObserver: .init())
            BubbleImageView(item: .init(id: "", isGroupChat: true, text: nil, type: .photo, ownerId: "", timestamp: nil, thumbnailUrl: "https://static.vecteezy.com/system/resources/thumbnails/036/135/738/small_2x/ai-generated-colored-water-drops-on-abstract-background-water-drops-on-colorful-background-colored-wallpaper-ultra-hd-colorful-wallpaper-background-with-colored-bubbles-photo.jpg", thumbnailWidth: nil, thumbnailHeight: nil, videoUrl: nil, audioURL: nil, audioDuration: nil), chatActionObserver: .init())
            
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}

