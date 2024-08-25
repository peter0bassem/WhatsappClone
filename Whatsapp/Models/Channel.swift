//
//  Channel.swift
//  Whatsapp
//
//  Created by iCommunity app on 24/08/2024.
//

import Foundation

struct Channel: Identifiable, Codable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationData: Date
    var lastMessageTimestamp: Date
    var membersCount: UInt
    var adminUids: [String]
    var memberUids: [String]
    var members: [User] = []
    var thumbinalUrl: String?
    var createdBy: String
    
    var isGroupChat: Bool {
        membersCount > 2
    }
    
    var membersExcludingMe: [User] {
        get async {
            guard let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId() else { return [] }
            return members.filter { $0.uid != currentUid }
        }
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
    
    static let placeholderChannel: Channel = .init(id: "1", lastMessage: "Hello World", creationData: .init(), lastMessageTimestamp: .init(), membersCount: 2, adminUids: [], memberUids: [], members: [], thumbinalUrl: nil, createdBy: "")
}
