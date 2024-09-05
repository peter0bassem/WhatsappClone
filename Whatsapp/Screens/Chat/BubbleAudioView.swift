//
//  BubbleAudioView.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI
import Combine
import AVKit

struct BubbleAudioView: View {
    private let item: Message
    private var chatActionObserver: PassthroughSubject<MessageType, Never>
    @State private var itemDirection: MessageDirection = .unset
    @State private var itemHorizontalAlignmnet: HorizontalAlignment = .center
    @State private var itemBackground: Color = .clear
    @State private var showGroupPartnerInfo: Bool = false
    @State private var sliderValue: Double = 0.0
    @State private var sliderRange: ClosedRange<Double>
    @State private var playbackTime: String = "00:00"
    @State private var isDraggingSlider: Bool = false
    
    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
    @State private var playbackState: VoiceMessagePlayer.PlaybackState = .stopped
    
    private var isCorrectVoiceMessage: Bool {
        voiceMessagePlayer.currentURL?.absoluteString == item.audioURL
    }
    
    init(item: Message, chatActionObserver: PassthroughSubject<MessageType, Never>) {
        self.item = item
        self.chatActionObserver = chatActionObserver
        let audioDuration = item.audioDuration ?? 0
        self._sliderRange = State(wrappedValue: 0...audioDuration)
    }
    
    var body: some View {
        HStack {
            if itemDirection == .sent { Spacer() }
            HStack(alignment: .bottom, spacing: 5) {
                if itemDirection == .received {
                    if showGroupPartnerInfo {
                        CircleProfileImageView(profileImageUrl: item.sender?.profileImageUrl, size: .mini)
                            .offset(y: 5)
                    }
                }
                audioAndMessageTextView()
                    .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
                    .frame(width: UIScreen.main.bounds.width * 0.70, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(5)
                    .background(itemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .applyTail(direction: itemDirection)
                
            }
            if itemDirection == .received { Spacer() }
        }
        .task {
            itemDirection = await item.direction
            itemHorizontalAlignmnet = await item.horizontalAlignment
            itemBackground = await item.backgroundColor
            showGroupPartnerInfo = await item.showGroupPartnerInfo
        }
        .onReceive(voiceMessagePlayer.$playbackState) { playbackState in
            observePlayState(state: playbackState)
        }
        .onReceive(voiceMessagePlayer.$currentAudioTime) { currentAudioTime in
            observeCurrentAudioTime(currentAudioTime: currentAudioTime)
        }
    }
    
    private func audioAndMessageTextView() -> some View {
        VStack(alignment: itemHorizontalAlignmnet, spacing: -15) { // spacing between text and time
            HStack(alignment: .center) {
                playButton()
                VStack(alignment: .leading) {
                    Spacer()
                    Slider(value: $sliderValue, in: sliderRange) { editing in
                        isDraggingSlider = editing
                        if !editing && isCorrectVoiceMessage {
                            voiceMessagePlayer.seek(to: sliderValue)
                        }
                    }
                    .introspect(.slider, on: .iOS(.v17)) { slider in
                        let image = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
                        slider.setThumbImage(image, for: .normal)
                    }
                    .tint(.gray)
                    
                    if playbackState == .stopped {
                        Text((item.audioDuration ?? 0.0).formatElapsedTime)
                            .foregroundStyle(.gray)
                            .font(.caption)
                    } else {
                        Text(playbackTime)
                            .foregroundStyle(.gray)
                            .font(.caption)
                    }
                }
                
            }
            .padding([.top, .horizontal], 10)
            timestampView()
        }
    }
    
    private func playButton() -> some View {
        Button {
            handlePlayVoiceMessage()
        } label: {
            Image(systemName: playbackState.icon)
                .imageScale(.large)
                .foregroundStyle(.gray)
                .offset(y: -5)
        }
    }
    
    private func timestampView() -> some View {
        HStack(spacing: 2) {
            Text((item.timestamp ?? 0.0).toDate().formatToTime)
                .font(.footnote/*.system(size: 13)*/)
                .foregroundStyle(.gray)
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

extension BubbleAudioView {
    private func handlePlayVoiceMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard
                let audioUrlString = item.audioURL,
                let audioURL = URL(string: audioUrlString)
            else { return }
            voiceMessagePlayer.playAudio(from: audioURL)
        } else {
            voiceMessagePlayer.pauseAudio()
        }
    }
    
    private func observePlayState(state: VoiceMessagePlayer.PlaybackState) {
        switch state {
        case .stopped:
            playbackState = .stopped
            sliderValue = 0
        case .playing, .paused:
            if isCorrectVoiceMessage {
                playbackState = state
            }
        }
    }
    
    private func observeCurrentAudioTime(currentAudioTime: CMTime) {
        guard voiceMessagePlayer.currentURL?.absoluteString == item.audioURL else { return }
        playbackTime = currentAudioTime.seconds.formatElapsedTime
        sliderValue = currentAudioTime.seconds
    }
}

#Preview {
    ScrollView {
        VStack {
            BubbleAudioView(item: .sentPlaceholder, chatActionObserver: .init())
            BubbleAudioView(item: .receivedPlaceholder, chatActionObserver: .init())
            BubbleAudioView(item: .init(id: "", isGroupChat: true, text: nil, type: .audio(audioURL: nil), ownerId: "", timestamp: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoUrl: nil, audioURL: nil, audioDuration: nil), chatActionObserver: .init())
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}
