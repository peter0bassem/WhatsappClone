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

final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack: [ChannelCreationRoute] = []
    @Published var selectedChatPartners: [User] = []
    @Published private(set) var users: [User] = []
    @Published private(set) var viewState: ViewState?
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
    
    var isPaginatable: Bool {
        return !users.isEmpty
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
    
    func handleItemSelection(_ item: User) {
        if isUserSelected(item) {
            // deselect
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            // select
            if selectedChatPartners.count >= ChannelConstants.maxGroupParticipants {
                print("maximum partners selected")
            } else {
                selectedChatPartners.append(item)
            }
        }
    }
    
    func isUserSelected(_ user: User) -> Bool {
        return selectedChatPartners.contains { $0.uid == user.uid }
    }
}

extension ChatPartnerPickerViewModel {
    enum ViewState {
        case loading
        case fetching
        case finished
    }
}
