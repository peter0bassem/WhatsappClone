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
    
    static func getChannelMembers(for channel: Channel) async -> [User] {
        let currentUid = await AuthProviderServiceImp.shared.getCurrentUserId() ?? ""
        if channel.isGroupChat {
            // fetch all members
            return await UserFirebaseManager.getUsers(withUserIds: channel.memberUids ?? [])
        } else {
            // fetch other member only
            return await UserFirebaseManager.getUsers(withUserIds: (channel.memberUids ?? []).filter { $0 != currentUid })
        }
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
                                        .map { Message(id: $0.messageId, isGroupChat: channel.isGroupChat, text: $0.message.text, type: $0.message.type, ownerId: $0.message.ownerId, timestamp: $0.message.timestamp) }
                
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
    
//    static func fetchUserChannels(withUserId userId: String) async -> AnyPublisher<[Channel], Error> {
//        let subject = PassthroughSubject<[Channel], Error>()
//        
//        FirebaseReferenceConstants.UserChannelsRef.child(userId).observe(.value) { snapshot in
//            guard let dict = snapshot.value as? [String: Any] else {
//                subject.send(completion: .failure(NSError(domain: "InvalidSnapshotData", code: -1, userInfo: nil)))
//                return
//            }
//            let channelIds = dict.map { $0.key } // gets key for user id in user-channels table
//            
//            // Fetch channels concurrently
//            Task {
//                let channels = try await withThrowingTaskGroup(of: Channel.self) { group -> [Channel] in
//                    for channelId in channelIds {
//                        group.addTask {
//                            return try await getChannel(withChannelId: channelId)
//                        }
//                    }
//                    
//                    var collectedChannels: [Channel] = []
//                    for try await channel in group {
//                        collectedChannels.append(channel)
//                    }
//                    return collectedChannels
//                }
//                subject.send(channels)
//            }
//        } withCancel: { error in
//            subject.send(completion: .failure(error))
//        }
//
//        
//        return subject.eraseToAnyPublisher()
//    }

    /// Fetches user channels using Combine and Firebase's .observe method.
    ///
    /// - Parameter userId: The ID of the user whose channels are to be fetched.
    /// - Returns: A publisher that emits an array of `Channel` objects or an `Error`.
    static func fetchUserChannels(withUserId userId: String) -> AnyPublisher<[Channel], Error> {
        // Create a PassthroughSubject to emit channel arrays and handle errors
        let subject = PassthroughSubject<[Channel], Error>()
        
        // Reference to the user's channels in Firebase
        let ref = FirebaseReferenceConstants.UserChannelsRef.child(userId)
        
        // Add the Firebase observer for .value events
        let handle = ref.observe(.value, with: { snapshot in
            // Process each snapshot in a separate Task to handle async operations
            Task {
                do {
                    // Parse the snapshot data
                    guard let dict = snapshot.value as? [String: Any] else {
                        // If no channels are found, emit an empty array
                        subject.send([])
                        return
                    }
                    
                    let channelIds = Array(dict.keys)
                    
                    // Fetch channels concurrently using a throwing task group
                    let channels = try await fetchChannelsConcurrently(channelIds: channelIds)
                    
                    // Emit the fetched channels
                    subject.send(channels)
                } catch {
                    // Emit any errors encountered during fetching
                    subject.send(completion: .failure(error))
                }
            }
        }, withCancel: { error in
            // Emit the cancellation error
            subject.send(completion: .failure(error))
        })
        
        // Handle the removal of the observer when the publisher is canceled
        return subject
            .handleEvents(receiveCancel: {
                // Remove the Firebase observer to prevent memory leaks
                ref.removeObserver(withHandle: handle)
            })
            .eraseToAnyPublisher()
    }
    
    // Fetches channels concurrently using a throwing task group.
    ///
    /// - Parameter channelIds: An array of channel IDs to fetch.
    /// - Returns: An array of `Channel` objects.
    /// - Throws: An error if any channel fetch fails.
    private static func fetchChannelsConcurrently(channelIds: [String]) async throws -> [Channel] {
        try await withThrowingTaskGroup(of: Channel.self) { group in
            // Add a fetch task for each channel ID
            for channelId in channelIds {
                group.addTask {
                    return try await getChannel(withChannelId: channelId)
                }
            }
            
            var collectedChannels: [Channel] = []
            
            // Collect the fetched channels as they complete
            for try await channel in group {
                collectedChannels.append(channel)
            }
            
            return collectedChannels
        }
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
