//
//  MediaAttachmentPreviewView.swift
//  Whatsapp
//
//  Created by iCommunity app on 28/08/2024.
//

import SwiftUI
import Combine

struct MediaAttachmentPreviewView: View {
    let attachments: [MediaAttachment]
    var actionObserver: PassthroughSubject<UserAction, Never>
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(attachments) { attachment in
                    switch attachment.type {
                    case .photo(_), .video(_, _):
                        thumbnailImageView(attachment: attachment)
                    case .audio:
                        audioAttachmentPreview(attachment: attachment)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: Constants.listHeight)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background(.whatsAppWhite)
    }
    
    private func thumbnailImageView(attachment: MediaAttachment) -> some View {
        ZStack {
            Button {
                
            } label: {
                Image(uiImage: attachment.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Constants.imageDimen, height: Constants.imageDimen)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        cancelButton(item: attachment)
                    }
                    .overlay(alignment: .center) {
                        switch attachment.type {
                        case .video(_, _):
                            playButton("play.fill", attachment: attachment)
                        default: EmptyView()
                        }
                    }
            }
            .buttonStyle(NoTapAnimationStyle())

//                .onTapGesture {
//                    switch attachment.type {
//                    case .photo(let imageAttachment):
//                        print("Trying to full screen image")
//                    default: break
//                    }
//                }
        }
    }
    
    private func cancelButton(item: MediaAttachment) -> some View {
        Button {
            actionObserver.send(.removeItem(item: item))
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .padding(5)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding([.top, .trailing], 2)
                .bold()
        }
    }
    
    private func playButton(_ title: String, attachment: MediaAttachment) -> some View {
        Button {
            actionObserver.send(.play(item: attachment))
        } label: {
            Image(systemName: title)
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding([.top, .trailing], 2)
                .bold()
        }
    }
    
    private func audioAttachmentPreview(attachment: MediaAttachment) -> some View {
        ZStack {
            LinearGradient(colors: [.green, .green.opacity(0.8), .teal], startPoint: .topLeading, endPoint: .bottom)
            playButton("mic.fill", attachment: attachment)
                .padding(.bottom, 15)
        }
        .frame(width: Constants.imageDimen * 2, height: Constants.imageDimen)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .overlay(alignment: .topTrailing) {
            cancelButton(item: attachment)
        }
        .overlay(alignment: .bottomLeading) {
            Text("Test mp3 file name here")
                .font(.caption)
                .padding(2)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
        }
    }
}

extension MediaAttachmentPreviewView {
    enum Constants {
        static let listHeight: CGFloat = 100
        static let imageDimen: CGFloat = 80
    }
}

#Preview {
    MediaAttachmentPreviewView(
        attachments: [
            .init(id: UUID().uuidString, type: .photo(imageAttachment: .stubImage0)),
            .init(id: UUID().uuidString, type: .photo(imageAttachment: .stubImage0)),
            .init(id: UUID().uuidString, type: .photo(imageAttachment: .stubImage1)),
            .init(id: UUID().uuidString, type: .photo(imageAttachment: .stubImage0))
        ],
        actionObserver: .init()
    )
}

struct NoTapAnimationStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Make the whole button surface tappable. Without this only content in the label is tappable and not whitespace. Order is important so add it before the tap gesture
            .contentShape(Rectangle())
            .onTapGesture(perform: configuration.trigger)
    }
}
