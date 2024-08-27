//
//  Channel.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation

struct Channel: Identifiable, Codable, Hashable {
    var id: String?
    var name: String?
    var lastMessage: String
    var creationData: TimeInterval?
    var lastMessageTimestamp: TimeInterval
    var membersCount: UInt?
    var adminUids: [String]?
    var memberUids: [String]?
    var members: [User]?
    private var thumbinalUrl: String?
    var createdBy: String?
    
    var coverImageUrl: String? {
        get async {
            if let thumbinalUrl = thumbinalUrl {
                return thumbinalUrl
            }
            if !isGroupChat {
                return await membersExcludingMe.first?.profileImageUrl
            }
            return nil
        }
    }
    
    var isGroupChat: Bool {
        (membersCount ?? 0) > 2
    }
    
    var membersExcludingMe: [User] {
        get async {
            guard let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId() else { return [] }
            return (members ?? []).filter { $0.uid != currentUid }
        }
    }
    
    var isCreatedByMe: Bool {
        get async {
            return await AuthProviderServiceImp.shared.getCurrentUserId() == createdBy
        }
    }
    
    var creatorName: String {
        return members?.first(where: { $0.uid == createdBy })?.username ?? "Someone"
    }
    
    var title: String {
        get async {
            if let channelName = name {
                return channelName
            }
            if isGroupChat {
                return await groupMemberNames
            } else {
                return await membersExcludingMe.first?.username ?? "Unknown"
            }
        }
    }
    
    var allMembersFetched: Bool {
        if isGroupChat {
            return members?.count == memberUids?.count
        }
        return members?.count == ((memberUids?.count ?? 0) - 1)
    }
    
    private var groupMemberNames: String {
        get async {
            let membersCount = await membersExcludingMe.count
            let fullNames = await membersExcludingMe.map { $0.username }
            if membersCount == 2 {
                // username1 and username2
                return fullNames.joined(separator: " and ")
            } else if membersCount > 2 {
                // username1, username2 and 10 others
                let remainingCounts = membersCount - 2
                return fullNames.prefix(2).joined(separator: ", ") + ", and \(remainingCounts) others"
            }
            return "Unknown."
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lastMessage
        case creationData
        case lastMessageTimestamp = "messageTimestamp"
        case membersCount
        case adminUids
        case memberUids
        case thumbinalUrl
        case createdBy
    }
    
    init(id: String? = nil, name: String? = nil, lastMessage: String, creationData: TimeInterval? = nil, lastMessageTimestamp: TimeInterval, membersCount: UInt? = nil, adminUids: [String]? = nil, memberUids: [String]? = nil, members: [User]? = nil, thumbinalUrl: String? = nil, createdBy: String? = nil) {
        self.id = id
        self.name = name
        self.lastMessage = lastMessage
        self.creationData = creationData
        self.lastMessageTimestamp = lastMessageTimestamp
        self.membersCount = membersCount
        self.adminUids = adminUids
        self.memberUids = memberUids
        self.members = members
        self.thumbinalUrl = thumbinalUrl
        self.createdBy = createdBy
    }
    
    static let placeholderChannel: Channel = .init(id: "1", lastMessage: "Hello World", creationData: .init(), lastMessageTimestamp: .init(), membersCount: 2, adminUids: [], memberUids: [], members: [], thumbinalUrl: nil, createdBy: "")
}
