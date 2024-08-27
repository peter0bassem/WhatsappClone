//
//  MessageFirebaseManager.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation
import FirebaseDatabase
import CodableFirebase
import Combine

actor MessageFirebaseManager {
    static func sendMessage(toChannel channelId: String, messageId: String, messageRequest: MessageRequest) throws {
        let encodedMessageRequest = try FirebaseEncoder().encode(messageRequest)
        FirebaseReferenceConstants.MessagesRef.child(channelId).child(messageId).setValue(encodedMessageRequest)
    }
    
    static func fetchUserChannels(withUserId userId: String) async throws -> [Channel] {
        return try await withCheckedThrowingContinuation { continuation in
            FirebaseReferenceConstants.UserChannelsRef.child(userId).observeSingleEvent(of: .value) { snapshot in
                Task {
                    do {
                        guard let dict = snapshot.value as? [String: Any] else {
                            continuation.resume(returning: [])
                            return
                        }
                        let channelIds = dict.map { $0.key } // gets key for user id in user-channels table
                        
                        // Fetch channels concurrently
                        let channels = try await withThrowingTaskGroup(of: Channel.self) { group -> [Channel] in
                            for channelId in channelIds {
                                group.addTask {
                                    return try await getChannel(withChannelId: channelId)
                                }
                            }
                            
                            var collectedChannels: [Channel] = []
                            for try await channel in group {
                                collectedChannels.append(channel)
                            }
                            return collectedChannels
                        }
                        
                        continuation.resume(returning: channels)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            } withCancel: { error in
                print("Failed to get the current user's channel ids: \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
        }
    }

    private static func getChannel(withChannelId channelId: String) async throws -> Channel {
        return try await withCheckedThrowingContinuation { continuation in
            FirebaseReferenceConstants.ChannelsRef.child(channelId).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found for channel ID: \(channelId)"]))
                    return
                }
                do {
                    let decodedChannel = try FirebaseDecoder().decode(Channel.self, from: value)
                    
                    // Fetch channel members asynchronously
                    Task {
                        let members = await getChannelMembers(for: decodedChannel)
                        var channelWithMembers = decodedChannel
                        channelWithMembers.members = members
                        continuation.resume(returning: channelWithMembers)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            } withCancel: { error in
                print("Failed to get the channel for id \(channelId): \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
        }
    }

//    static func fetchUserChannels(withUserId userId: String) async throws -> [Channel] {
//        try await withCheckedThrowingContinuation { continuation in
//            FirebaseReferenceConstants.UserChannelsRef.child(userId).observe(.value) { snapshot in
//                Task {
//                    do {
//                        guard let dict = snapshot.value as? [String: Any] else {
////                            continuation.resume(returning: [])
//                            return
//                        }
//                        let channelIds = dict.map { $0.key } // gets key for user id in user-channels table
//                        
//                        // Use async/await to fetch channels concurrently
//                        let channels = try await withThrowingTaskGroup(of: Channel.self) { group -> [Channel] in
//                            for channelId in channelIds {
//                                group.addTask {
//                                    return try await getChannel(withChannelId: channelId)
//                                }
//                            }
//                            
//                            var collectedChannels: [Channel] = []
//                            for try await channel in group {
//                                collectedChannels.append(channel)
//                            }
//                            return collectedChannels
//                        }
//                        
//                        continuation.resume(returning: channels)
//                    } catch {
//                        continuation.resume(throwing: error)
//                    }
//                }
//            } withCancel: { error in
//                print("Failed to get the current user's channel ids: \(error.localizedDescription)")
//                continuation.resume(throwing: error)
//            }
//        }
//    }
//    
//    private static func getChannel(withChannelId channelId: String) async throws -> Channel {
//        try await withCheckedThrowingContinuation { continuation in
//            FirebaseReferenceConstants.ChannelsRef.child(channelId).observeSingleEvent(of: .value) { snapshot in
//                guard let value = snapshot.value else {
//                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found for channel ID: \(channelId)"]))
//                    return
//                }
//                do {
//                    let decodedChannel = try FirebaseDecoder().decode(Channel.self, from: value)
//                    Task {
//                        let members = await getChannelMembers(for: decodedChannel)
//                        var channelWithMembers = decodedChannel
//                        channelWithMembers.members = members
//                        continuation.resume(returning: channelWithMembers)
//                    }
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            } withCancel: { error in
//                print("Failed to get the channel for id \(channelId): \(error.localizedDescription)")
//                continuation.resume(throwing: error)
//            }
//        }
//    }
    
    private static func getChannelMembers(for channel: Channel) async -> [User] {
        await UserFirebaseManager.getUsers(withUserIds: channel.memberUids ?? [])
    }
    
    static func sendTextMessage(toChannel channel: Channel, fromUser user: User, textMessage: String) async throws {
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseReferenceConstants.MessagesRef.childByAutoId().key else { return }
        
        let updatedChannelDictionary = try Channel(lastMessage: textMessage, lastMessageTimestamp: timestamp).asDictionary()
        
        let message = MessageRequest(text: textMessage, type: MessageType.text.title, timestamp: timestamp, ownerId: user.uid)
        let encodedMessage = try FirebaseEncoder().encode(message)
        
        try await FirebaseReferenceConstants.ChannelsRef.child(channel.id.removeOptional).updateChildValues(updatedChannelDictionary)
        try await FirebaseReferenceConstants.MessagesRef.child(channel.id.removeOptional).child(messageId).setValue(encodedMessage)
    }
    
//    static func getMessages(forChannel channel: Channel) async throws -> [Message] {
//        try await withCheckedThrowingContinuation { continuation in
//            FirebaseReferenceConstants.MessagesRef.child(channel.id.removeOptional).observe(.value) { snapshot in
//                guard let value = snapshot.value as? [String: Any] else {
//                    continuation.resume(throwing: NSError(domain: "InvalidSnapshotData", code: -1, userInfo: nil))
//                    return
//                }
//                do {
//                    /// first map gets the message key and the message object.
//                    /// second map gets message key and decoded Message object.
//                    /// third map adds the message id to the message object.
//                    let messages = try value.map { (messageId: $0.key, message: $0.value) }
//                        .map { (messageId: $0.messageId, message: try FirebaseDecoder().decode(Message.self, from: $0.message)) }
//                        .map { Message(id: $0.messageId, text: $0.message.text, type: $0.message.type, ownerId: $0.message.ownerId) }
//                    
//                    // Return the messages array
//                    continuation.resume(returning: messages)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            } withCancel: { error in
//                continuation.resume(throwing: error)
//            }
//        }
//    }

    static func getMessages(forChannel channel: Channel) -> AnyPublisher<[Message], Error> {
        let subject = PassthroughSubject<[Message], Error>()

        FirebaseReferenceConstants.MessagesRef.child(channel.id.removeOptional).observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                subject.send(completion: .failure(NSError(domain: "InvalidSnapshotData", code: -1, userInfo: nil)))
                return
            }
            do {
                // Mapping and decoding the messages
                let messages = try value.map { (messageId: $0.key, message: $0.value) }
                                        .map { (messageId: $0.messageId, message: try FirebaseDecoder().decode(Message.self, from: $0.message)) }
                                        .map { Message(id: $0.messageId, text: $0.message.text, type: $0.message.type, ownerId: $0.message.ownerId, timestamp: $0.message.timestamp) }
                
                // Send the new messages to the subscriber
                subject.send(messages)
            } catch {
                subject.send(completion: .failure(error))
            }
        } withCancel: { error in
            subject.send(completion: .failure(error))
        }

        return subject.eraseToAnyPublisher()
    }


}

struct ChannelRequest: Codable {
    let lastMessage: String
    let lastMessageTimestmp: String
    
}

extension Encodable {
    func dictionary() -> [String:Any] {
        var dict = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let key = child.label else { continue }
            let childMirror = Mirror(reflecting: child.value)
            
            switch childMirror.displayStyle {
            case .struct, .class:
                let childDict = (child.value as! Encodable).dictionary()
                dict[key] = childDict
            case .collection:
                let childArray = (child.value as! [Encodable]).map({ $0.dictionary() })
                dict[key] = childArray
            case .set:
                let childArray = (child.value as! Set<AnyHashable>).map({ ($0 as! Encodable).dictionary() })
                dict[key] = childArray
            default:
                dict[key] = child.value
            }
        }
        
        return dict
    }
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
