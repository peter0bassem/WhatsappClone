//
//  BubbleAudioView.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem
    @State private var sliderValue: Double = 0.0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    var body: some View {
        HStack {
            if item.direction == .sent { Spacer() }
            HStack {
                audioAndMessageTextView()
                    .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
                    .frame(width: UIScreen.main.bounds.width * 0.70, alignment: .leading)
                    .background(item.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .applyTail(direction: item.direction)
                
            }
            if item.direction == .received { Spacer() }
        }
    }
    
    private func audioAndMessageTextView() -> some View {
        VStack(alignment: item.horizontalAlignment, spacing: -15) { // spacing between text and time
            HStack(alignment: .center) {
                playButton()
                VStack(alignment: .leading) {
                    Spacer()
                    Slider(value: $sliderValue, in: sliderRange)
                        .controlSize(.mini)
                        .tint(.gray)
                    Text("04:00")
                        .foregroundStyle(.gray)
                        .font(.caption)
                }
                
            }
            .padding([.top, .horizontal], 10)
            timestampView()
        }
    }
    
    private func playButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "play.fill")
//                .padding()
                .imageScale(.large)
//                .background(item.direction == .received ? .green : .white)
                .clipShape(Circle())
                .foregroundStyle(.gray)
                .offset(y: -4)
//                .foregroundStyle(item.direction == .received ? .white : .black)
        }

    }
    
    private func timestampView() -> some View {
        HStack(spacing: 2 ) {
            Text("3:05 PM")
                .font(.caption2/*.system(size: 13)*/)
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
        VStack {
            BubbleAudioView(item: .sentPlaceholder)
            BubbleAudioView(item: .receivedPlaceholder)
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}
