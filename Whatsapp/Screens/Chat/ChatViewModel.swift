//
//  ChatViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 26/08/2024.
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messageText: String = ""
    @Published var currentUser: User?
    @Published var messages: [Message] = []
    var sendMessageSingleObserver = PassthroughSubject<Void, Never>()
    private let channel: Channel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(channel: Channel) {
        self.channel = channel
        observerListeners()
        Task {
            await listenToAuthState()
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        DispatchQueue.main.async { [weak self] in
            self?.currentUser = nil
        }
    }
    
    private func observerListeners() {
        sendMessageSingleObserver
            .sink { [weak self] _ in
                self?.sendMessage()
            }
            .store(in: &cancellables)
    }
    
    private func listenToAuthState() async {
        await AuthProviderServiceImp.shared.authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                switch authState {
                case .loggedIn(let userViewModel):
                    self?.currentUser = userViewModel.user
                    self?.getMessages()
                default: break
                }
            }
            .store(in: &cancellables)
    }
    
    /// send text message
    func sendMessage() {
        guard let currentUser = currentUser else { return }
        Task {
            do {
                try await MessageServiceImpl.shared.sendTextMessage(toChannel: channel, fromUser: currentUser, textMessage: messageText)
                self.messageText = ""
                print("MessageServiceImpl is sending...")
            } catch {
                print("Failed to send message \(messageText): \(error.localizedDescription)")
            }
        }
    }
    
    var cancellable: AnyCancellable?
    
    private func getMessages() {
//        Task {
//            do {
//                let messages = try await MessageServiceImpl.shared.getMessages(forChannel: channel)
//                print("messages: \(messages)")
//            } catch {
//                print("Failed to get messages fro channel \(channel.id.removeOptional): \(error.localizedDescription)")
//            }
//        }
        
        Task {
            await MessageServiceImpl.shared.getMessages(forChannel: channel)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished observing messages.")
                    case .failure(let error):
                        print("Failed to observe messages: \(error)")
                    }
                }, receiveValue: { [weak self] messages in
                    self?.messages = messages.sorted(by: { ($0.timestamp ?? 0.0) < ($1.timestamp ?? 0.0) })
                })
                .store(in: &cancellables)
        }
    }
}
