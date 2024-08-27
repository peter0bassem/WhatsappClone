//
//  BubbleAudioView.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI
import SwiftUIIntrospect

struct BubbleAudioView: View {
    let item: Message
    @State private var itemDirection: MessageDirection = .unset
    @State private var itemHorizontalAlignmnet: HorizontalAlignment = .center
    @State private var itemBackground: Color = .clear
    @State private var sliderValue: Double = 0.0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    var body: some View {
        HStack {
            if itemDirection == .sent { Spacer() }
            HStack {
                audioAndMessageTextView()
                    .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0.0, y: 20.0)
                    .frame(width: UIScreen.main.bounds.width * 0.70, alignment: .leading)
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
        }
    }
    
    private func audioAndMessageTextView() -> some View {
        VStack(alignment: itemHorizontalAlignmnet, spacing: -15) { // spacing between text and time
            HStack(alignment: .center) {
                playButton()
                VStack(alignment: .leading) {
                    Spacer()
                    Slider(value: $sliderValue, in: sliderRange)
                        .introspect(.slider, on: .iOS(.v17)) { slider in
                            let image = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
                            slider.setThumbImage(image, for: .normal)
                        }
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
            BubbleAudioView(item: .sentPlaceholder)
            BubbleAudioView(item: .receivedPlaceholder)
        }
        .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.5))
}
