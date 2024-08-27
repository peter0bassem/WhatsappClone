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
    private var channel: Channel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(channel: Channel) {
        self.channel = channel
        Task {
            print("channel \(await self.channel.title) members: \(self.channel.members?.compactMap { $0.username })")
            guard let currentUserUid = await AuthProviderServiceImp.shared.getCurrentUserId(),
                  let members = channel.members,
                  let currentUserIndexSet = members.firstIndex(where: { $0.uid == currentUserUid })
            else { return }
            
            self.channel.members?.move(fromIndex: currentUserIndexSet, toIndex: 0)
            print("channel \(await self.channel.title) sorted members: \(self.channel.members?.compactMap { $0.username })")
            print("================================================================")
            
        }
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

extension Array {
    mutating func move(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex,
              indices.contains(fromIndex),
              indices.contains(toIndex) else { return }

        let element = self[fromIndex]
        remove(at: fromIndex)

        if toIndex > fromIndex {
            insert(element, at: toIndex - 1)
        } else {
            insert(element, at: toIndex)
        }
    }
}
