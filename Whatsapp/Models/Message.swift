//
//  Message.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import Foundation
import SwiftUI

struct Message: Identifiable, Codable, Hashable {
    var id: String?
    let isGroupChat: Bool?
    let text: String?
    let type: MessageType?
    let ownerId: String?
    let timestamp: TimeInterval?
    let thumbnailUrl: String?
    let thumbnailWidth: CGFloat?
    let thumbnailHeight: CGFloat?
    let videoUrl: String?
    let audioURL: String?
    let audioDuration: TimeInterval?
    
    var sender: User?
    
    var direction: MessageDirection {
        get async {
            ownerId == (await AuthProviderServiceImp.shared.getCurrentUserId() ?? "RfZDo1E35IVnZUH4C14pEgr7wxH2"/*.removeOptional*/) ? .sent : .received
        }
    }
    
    var backgroundColor: Color {
        get async {
            return (await direction) == .sent ? Color.bubbleGreen : Color.bubbleWhite
        }
    }
    var alignment: Alignment {
        get async {
            return (await direction) == .received ? .leading : .trailing
        }
    }
    var horizontalAlignment: HorizontalAlignment {
        get async {
            return (await direction) == .received ? .leading : .trailing
        }
    }
    
    var showGroupPartnerInfo: Bool {
        get async {
            return (await direction) == .received && isGroupChat == true
        }
    }
    
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0.0
        let photoHeight = thumbnailHeight ?? 0.0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWidth)
        return .init(width: imageWidth, height: imageHeight)
    }
    
    private var imageWidth: CGFloat {
        return (UIWindowScene.current?.screenWidth ?? 0.0) * 0.70
    }
    
    // Implementing the `Equatable` protocol
        static func ==(lhs: Message, rhs: Message) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.isGroupChat == rhs.isGroupChat &&
                   lhs.text == rhs.text &&
                   lhs.type == rhs.type &&
                   lhs.ownerId == rhs.ownerId &&
                   lhs.timestamp == rhs.timestamp &&
                   lhs.thumbnailUrl == rhs.thumbnailUrl &&
                   lhs.thumbnailWidth == rhs.thumbnailWidth &&
                   lhs.thumbnailHeight == rhs.thumbnailHeight &&
                   lhs.videoUrl == rhs.videoUrl &&
                   lhs.audioURL == rhs.audioURL &&
                   lhs.audioDuration == rhs.audioDuration
        }
        
        // Implementing the `Hashable` protocol
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(isGroupChat)
            hasher.combine(text)
            hasher.combine(type)
            hasher.combine(ownerId)
            hasher.combine(timestamp)
            hasher.combine(thumbnailUrl)
            hasher.combine(thumbnailWidth)
            hasher.combine(thumbnailHeight)
            hasher.combine(videoUrl)
            hasher.combine(audioURL)
            hasher.combine(audioDuration)
        }
        
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
        self.isGroupChat = try container.decodeIfPresent(Bool.self, forKey: .isGroupChat)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        
        self.ownerId = try container.decodeIfPresent(String.self, forKey: .ownerId)
        self.timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        self.thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        self.thumbnailWidth = try container.decodeIfPresent(CGFloat.self, forKey: .thumbnailWidth)
        self.thumbnailHeight = try container.decodeIfPresent(CGFloat.self, forKey: .thumbnailHeight)
        self.videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        self.audioURL = try container.decodeIfPresent(String.self, forKey: .audioURL)
        self.audioDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .audioDuration)
        
        self.type = MessageType(type ?? "", fileURL: URL(string: self.videoUrl.removeOptional))
    }
    
    init(id: String?, isGroupChat: Bool?, text: String?, type: MessageType?, ownerId: String?, timestamp: TimeInterval?, thumbnailUrl: String?, thumbnailWidth: CGFloat?, thumbnailHeight: CGFloat?, videoUrl: String?, audioURL: String?, audioDuration: TimeInterval?) {
        self.id = id
        self.isGroupChat = isGroupChat
        self.text = text
        self.type = type
        self.ownerId = ownerId
        self.timestamp = timestamp
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
        self.videoUrl = videoUrl
        self.audioURL = audioURL
        self.audioDuration = audioDuration
    }
    
    static let sentPlaceholder = Message(id: UUID().uuidString, isGroupChat: true, text: "Hi!", type: .text, ownerId: "RfZDo1E35IVnZUH4C14pEgr7wxH2", timestamp: nil, thumbnailUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGi4gPwjRV_OZLBzt0llgZxYsgmVRLt9z6gA&s", thumbnailWidth: nil, thumbnailHeight: nil, videoUrl: nil, audioURL: nil, audioDuration: nil) //Holy Spagetti, this is a dummy text for multi-line text view testing purpose.
    static let receivedPlaceholder = Message(id: UUID().uuidString, isGroupChat: false, text: "", type: .text, ownerId: "2", timestamp: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoUrl: nil, audioURL: nil, audioDuration: nil)
}
