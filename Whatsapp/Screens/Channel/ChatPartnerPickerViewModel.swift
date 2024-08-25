//
//  ChatPartnerPickerViewModel.swift
//  Whatsapp
//
//  Created by iCommunity app on 23/08/2024.
//

import Foundation

enum ChannelCreationRoute {
    case groupParnterPicker
    case setupGroupChat
}

enum ChannelConstants {
    static let maxGroupParticipants = 12
}

enum ChannelCreationError: Error {
    case noChatPartners
    case failedToGetIds
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack: [ChannelCreationRoute] = []
    @Published var selectedChatPartners: [User] = []
    @Published private(set) var users: [User] = []
    @Published private(set) var viewState: ViewState?
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "")
    private var lastCursor: String?
    private var totalUsers: Int?
    
    var showSelectedUsers: Bool {
        return !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartners.isEmpty
    }
    
    var isLoading: Bool {
        viewState == .loading
    }
    
    var isFetching: Bool {
        viewState == .fetching
    }
    
    private var isDirectChannel: Bool {
        return selectedChatPartners.count == 1
    }
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    @MainActor
    func fetchUsers() async {
        guard totalUsers != users.count else { return }
        if lastCursor == nil {
            viewState = .loading
        } else {
            viewState = .fetching
        }
        defer { viewState = .finished }
        do {
            let userNode = try await UserServiceImp.shared.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            if lastCursor == nil {
                self.totalUsers = userNode.totalUsersCount - 1
            }
            guard let currentUserId = await AuthProviderServiceImp.shared.getCurrentUserId() else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUserId } // remove current user.. later we will add it to chat ourselves.
            self.users.append(contentsOf: fetchedUsers)
            self.lastCursor = userNode.currentCursor
        } catch {
            print("Failed to fetch users \(error)")
        }
    }
    
    func hasReachedEnd(of user: User) -> Bool {
        users.last?.uid == user.uid
    }
    
    func deselectAllChatPartners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.selectedChatPartners.removeAll()
        }
    }
    
    func handleItemSelection(_ item: User) {
        if isUserSelected(item) {
            // deselect
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            // select
            guard selectedChatPartners.count < ChannelConstants.maxGroupParticipants else {
                showError("Sorry, We only allow a maximum of \(ChannelConstants.maxGroupParticipants) participants in group chat")
                return
            }
            selectedChatPartners.append(item)
        }
    }
    
    func isUserSelected(_ user: User) -> Bool {
        return selectedChatPartners.contains { $0.uid == user.uid }
    }
    
    func createDirectChannel(withPartner partner: User) async -> Channel? {
        selectedChatPartners.append(partner)
        do {
            // if existing DM, get the channel
            if let channelId = try await verifyIfDirectChannelExists(withChatPartnerId: partner.uid) {
                if var channel = try await ChannelServiceImp.shared.getChannel(forChannelId: channelId) {
                    channel.members = selectedChatPartners
                    return channel
                } else {
                    print("No Channel found for channel id: \(channelId)")
                    return nil
                }
            } else {
                // create a new DM with the user.
                let channelCreationResult = await createChannel(channelName: nil)
                switch channelCreationResult {
                case .success(let success):
                    return success
                case .failure(let failure):
                    print("Failed to create a direct channel \(failure.localizedDescription)")
                    showError("Sorry! Something went wrong while we were trying to setup your chat.")
                    return nil
                }
            }
        } catch {
            print("Failed to create a direct channel \(error.localizedDescription)")
            showError("Sorry! Something went wrong while we were trying to setup your chat.")
            return nil
        }
    }
    
    typealias ChannelID = String
    private func verifyIfDirectChannelExists(withChatPartnerId chatPartnerId: String) async throws -> ChannelID? {
        guard let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId()
        else { return nil }
        let snapshotResult = try await ChannelServiceImp.shared.verifyDirectChatChannelExists(withUser: currentUid, partnerId: chatPartnerId)
        if snapshotResult.snapshotExists {
            return snapshotResult.channelId
        }
        return nil
    }
    
    func createGroupChannel(_ groupName: String?) async -> Channel? {
        let channelCreationResult = await createChannel(channelName: groupName)
        switch channelCreationResult {
        case .success(let success):
            return success
        case .failure(let failure):
            print("Failed to create a group channel \(failure.localizedDescription)")
            showError("Sorry! Something went wrong while we were trying to setup your chat.")
            return nil
        }
    }
    
    private func showError(_ errorMessage: String) {
        errorState = (true, errorMessage)
    }
    
    private func createChannel(channelName: String?) async -> Result<Channel, Error> {
        guard !selectedChatPartners.isEmpty else { return .failure(ChannelCreationError.noChatPartners) }
        
        guard let channelId = await ChannelServiceImp.shared.createChannelIdKey(),
              let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId(),
              let messageId = FirebaseReferenceConstants.MessagesRef.childByAutoId().key
        else { return .failure(ChannelCreationError.failedToGetIds) }
        
        let timestamp = Date().timeIntervalSince1970
        let membersUids = selectedChatPartners.compactMap { $0.uid } + [currentUid]
        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue
        var channelRequest: ChannelCreationRequest = .init(id: channelId, lastMessage: newChannelBroadcast, creationData: timestamp, messageTimestamp: timestamp, membersCount: UInt(membersUids.count), adminUids: [currentUid], memberUids: membersUids, thumbnailUrl: nil, createdBy: currentUid)
        if let channelName = channelName, !channelName.isEmptyOrWhiteSpace {
            channelRequest = channelRequest.updateChannelName(newChannelName: channelName)
        }
        let messageRequest = MessageRequest(type: newChannelBroadcast, timestamp: timestamp, ownerId: currentUid)
        
        do {
            try await ChannelServiceImp.shared.createChannel(channelRequest, withChannelKey: channelId)
            try await MessageServiceImpl.shared.sendMessage(toChannel: channelId, messageId: messageId, messageRequest: messageRequest)
            for userId in membersUids {
                // keeping an index of the channel that a specific user belongs to.
                await ChannelServiceImp.shared.updateUserChannelIdValue(forUserId: userId, channelId: channelId, value: true)
            }
            
            // makes sure that a channel is unique.
            if isDirectChannel {
                let chatPartner = selectedChatPartners[0]
                await ChannelServiceImp.shared.updateUserDirectChannelValue(forUserId: currentUid, partnerId: chatPartner.uid, channelId: channelId, value: true)
                await ChannelServiceImp.shared.updateUserDirectChannelValue(forUserId: chatPartner.uid, partnerId: currentUid, channelId: channelId, value: true)
            }
            
            let newChannel = Channel(
                id: channelRequest.id,
                name: channelRequest.name,
                lastMessage: channelRequest.lastMessage,
                creationData: .init(timeIntervalSince1970: channelRequest.creationData),
                lastMessageTimestamp: .init(timeIntervalSinceNow: channelRequest.messageTimestamp),
                membersCount: channelRequest.membersCount,
                adminUids: channelRequest.adminUids,
                memberUids: channelRequest.memberUids,
                members: selectedChatPartners,
                thumbinalUrl: channelRequest.thumbnailUrl,
                createdBy: channelRequest.createdBy
            )
            return .success(newChannel)
        } catch {
            print("Failed to create channel \(error)")
            return .failure(error)
        }
    }
}

extension ChatPartnerPickerViewModel {
    enum ViewState {
        case loading
        case fetching
        case finished
    }
}

struct ChannelCreationRequest: Codable {
    let id: String
    var name: String? = nil
    let lastMessage: String
    let creationData: TimeInterval
    let messageTimestamp: TimeInterval
    let membersCount: UInt
    let adminUids: [String]
    let memberUids: [String]
    let thumbnailUrl: String?
    let createdBy: String
    
    func updateChannelName(newChannelName: String) -> Self {
        return .init(id: self.id, name: newChannelName, lastMessage: self.lastMessage, creationData: self.creationData, messageTimestamp: self.messageTimestamp, membersCount: self.membersCount, adminUids: self.adminUids, memberUids: self.memberUids, thumbnailUrl: self.thumbnailUrl, createdBy: self.createdBy)
    }
}

struct MessageRequest: Codable {
    let type: String
    let timestamp: TimeInterval
    let ownerId: String
}
