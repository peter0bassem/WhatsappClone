//
//  ChatViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 26/08/2024.
//

import Foundation
import Combine
import PhotosUI
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messageText: String = ""
    @Published var isRecordingVoiceMessage: Bool = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var currentUser: User?
    @Published var messages: [Message] = []
    @Published var showPhotoPicker: Bool = false
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var selectedAttachments: [MediaAttachment] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    var actionObserver = PassthroughSubject<UserAction, Never>()
    private var channel: Channel
    
    var showPhotoPickerPreview: Bool {
        !photoPickerItems.isEmpty || !selectedAttachments.isEmpty
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let audioRecorderService = AudioRecorderService()
    private var previousPhotoPickerItems: [PhotosPickerItem] = []
    
    init(channel: Channel) {
        self.channel = channel
        Task {
            print("channel \(await self.channel.title) members: \(self.channel.members?.compactMap { $0.username } ?? [])")
            guard let currentUserUid = await AuthProviderServiceImp.shared.getCurrentUserId(),
                  let members = channel.members,
                  let currentUserIndexSet = members.firstIndex(where: { $0.uid == currentUserUid })
            else { return }
            
            self.channel.members?.move(fromIndex: currentUserIndexSet, toIndex: 0)
            print("channel \(await self.channel.title) sorted members: \(self.channel.members?.compactMap { $0.username } ?? [])")
            print("================================================================")
            
        }
        observerListeners()
        Task {
            await listenToAuthState()
        }
        
       
        
        $photoPickerItems
            .dropFirst()
            .sink { [weak self] photoItems in
                guard let self = self else { return }
                if photoItems.count > self.previousPhotoPickerItems.count {
                    Task {
//                        self.selectedAttachments = []
                        let audioRecordings = self.selectedAttachments.filter({ $0.type == .audio(audioURL: .init(string: "https://www.google.com")!, duration: 0) })
                        self.selectedAttachments = audioRecordings
                        for photoPickerItem in self.photoPickerItems {
                            if photoPickerItem.isVideo {
                                do {
                                    if let movie = try await photoPickerItem.loadTransferable(type: VideoPickerTranferable.self),
                                       let thumbnailImage = try await movie.url.generateThumbnail() {
                                        let videoAttachment = MediaAttachment(id: photoPickerItem.itemIdentifier, type: .video(thumbnailImage: thumbnailImage, videoURL: movie.url))
                                        self.selectedAttachments.insert(videoAttachment, at: 0)
                                    }
                                } catch {
                                    
                                }
                            } else {
                                do {
                                    guard let data = try await photoPickerItem.loadTransferable(type: Data.self),
                                          let uiImage = UIImage(data: data)
                                    else { return }
                                    let photoAttachment = MediaAttachment(id: photoPickerItem.itemIdentifier, type: .photo(imageAttachment: uiImage))
                                    self.selectedAttachments.insert(photoAttachment, at: 0)
                                } catch {
                                    print("Failed to get uiimage from image \(error)")
                                }
                            }
                        }
                    }
                }
                self.previousPhotoPickerItems = photoItems
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        DispatchQueue.main.async { [weak self] in
            self?.currentUser = nil
        }
        audioRecorderService.tearDown()
    }
    
    private func observerListeners() {
        actionObserver
            .sink { [weak self] action in
                switch action {
                case .presentPhotoPicker:
                    self?.showPhotoPicker.toggle()
                case .sendMessage:
                    self?.sendMessage()
                case .play(let attachment):
                    guard let fileURL = attachment.fileURL else { return }
                    self?.showMediaPlayer(for: fileURL)
                case .removeItem(let item):
                    withAnimation {
                        guard let self = self,
                              let itemIndex = self.selectedAttachments.firstIndex(where: { $0.id == item.id })
                        else { return }
                        let attachment = self.selectedAttachments[itemIndex]
                        self.selectedAttachments.remove(at: itemIndex)
                        
                        switch attachment.type {
                        case .photo, .video:
                            guard let photoItemIndex = self.photoPickerItems.firstIndex(where: { $0.itemIdentifier == item.id }) else { return }
                            self.photoPickerItems.remove(at: photoItemIndex)
                        case .audio(let fileURL, _):
                            self.audioRecorderService.deleteRecording(at: fileURL)
                        }
                        
                        
                    }
                case .recordAudio:
                    if self?.audioRecorderService.isRecording == true {
                        // stop recording
                        Task {
                            guard let stopRecordingData = await self?.audioRecorderService.stopRecording() else { return }
                            self?.createAudioAttachment(from: stopRecordingData.audioURL, audioDuration: stopRecordingData.audioDuration)
                        }
                    } else {
                        // start recording
                        self?.audioRecorderService.startRecording()
                    }
                }
            }
            .store(in: &cancellables)
        
        audioRecorderService.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecordingVoiceMessage = isRecording
            }
            .store(in: &cancellables)
        
        audioRecorderService.$elapsedTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] elapsedTime in
                self?.elapsedVoiceMessageTime = elapsedTime
            }
            .store(in: &cancellables)
    }
    
    private func createAudioAttachment(from audioURL: URL?, audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL: audioURL, duration: audioDuration))
        selectedAttachments.insert(audioAttachment, at: 0)
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
    
    func showMediaPlayer(for fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = .init(url: fileURL)
    }
    
    func dismissMediaPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
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
