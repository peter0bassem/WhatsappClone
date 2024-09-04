//
//  TextInputAreaView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI
import Combine

struct TextInputAreaView: View {
    @State private var isPulsing: Bool = false
    @Binding var messageText: String
    @Binding var isRecording: Bool
    @Binding var elapsedTime: TimeInterval
    var actionObserver: PassthroughSubject<UserAction, Never>
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    private var isSendButtonDisabled: Bool {
        chatViewModel.disableSendButton || isRecording
        
    }
    
    var body: some View {
        HStack(alignment: .bottom ,spacing: 5) {
            imagePickerButton()
                .padding(3)
                .disabled(isRecording)
                .grayscale(isRecording ? 0.8 : 1.0)
            audioRecorderButton()
            if isRecording {
                audioSessionIndicatorView()
            } else {
                messageTextField()
            }
            sendMessageButton()
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .background(.whatsAppWhite)
        .animation(.spring, value: isRecording)
        .onChange(of: isRecording) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
    
    private func audioSessionIndicatorView() -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .scaleEffect(isPulsing ? 1.8 : 1.0)
            
            Text("Recording Audio")
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Text(elapsedTime.formatElapsedTime)
                .font(.callout)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .clipShape(Capsule())
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.blue.opacity(0.1))
        )
        .overlay(textViewBorder())
    }
    
    private func messageTextField() -> some View {
        TextField("", text: $messageText, axis: .vertical)
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.thinMaterial))
            .overlay(textViewBorder())
    }
    
    private func textViewBorder() -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color(.systemGray5), lineWidth: 1)
    }
    
    private func imagePickerButton() -> some View {
        Button {
            actionObserver.send(.presentPhotoPicker)
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 22))
        }

    }
    
    private func audioRecorderButton() -> some View {
        Button {
            actionObserver.send(.recordAudio)
        } label: {
            Image(systemName: isRecording ? "square.fill" : "mic.fill")
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(6)
                .background(isRecording ? .red : .blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }
    
    private func sendMessageButton() -> some View {
        Button {
            actionObserver.send(.sendMessage)
        } label: {
            Image(systemName: "arrow.up")
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .padding(6)
                .background(.blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
        .disabled(isSendButtonDisabled)
        .grayscale(isSendButtonDisabled ? 0.8 : 0.0)
    }
}

    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case play(item: MediaAttachment)
        case removeItem(item: MediaAttachment)
        case recordAudio
    }

#Preview {
    TextInputAreaView(messageText: .constant(""), isRecording: .constant(false), elapsedTime: .constant(0), actionObserver: .init())
        .environmentObject(ChatViewModel(channel: .placeholderChannel))
}
