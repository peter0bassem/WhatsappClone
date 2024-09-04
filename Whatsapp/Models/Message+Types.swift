//
//  Message+Types.swift
//  Whatsapp
//
//  Created by iCommunity app on 25/08/2024.
//

import Foundation

enum AdminMessageType: String, Codable {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageDirection: Codable {
    case unset,sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, MessageDirection.received].randomElement() ?? .sent
    }
    
}

enum MessageType: Equatable, Codable, Hashable {
    case admin(type: AdminMessageType)
    case text
    case photo
    case video(videoURL: URL?)  // Added associated value
    case audio(audioURL: URL?)
    
    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        }
    }
    
    init?(_ stringValue: String, fileURL: URL? = nil) {
        switch stringValue {
        case "text": self = .text
        case "photo": self = .photo
        case "video": self = .video(videoURL: fileURL)
        case "audio": self = .audio(audioURL: fileURL)
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(type: adminMessageType)
            } else {
                return nil
            }
        }
    }
    
    // Conformance to Codable and Hashable can be tricky with associated values.
    // We'll need to implement custom encoding/decoding and hashing.
}

// To implement custom Codable and Hashable conformance, you would typically need to write custom methods.
// Below is a general approach to handling this.

extension MessageType {
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case admin
        case text
        case photo
        case video
        case audio
        case videoURL
        case audioURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let adminMessageType = try? container.decode(AdminMessageType.self, forKey: .admin) {
            self = .admin(type: adminMessageType)
        } else if let _ = try? container.decode(String.self, forKey: .text) {
            self = .text
        } else if let _ = try? container.decode(String.self, forKey: .photo) {
            self = .photo
        } else if let videoURL = try? container.decode(URL.self, forKey: .videoURL) {
            self = .video(videoURL: videoURL)
        }  else if let audioURL = try? container.decode(URL.self, forKey: .audioURL) {
            self = .audio(audioURL: audioURL)
        }
//        else if let _ = try? container.decode(String.self, forKey: .audio) {
//            self = .audio
//        }
        else {
            throw DecodingError.dataCorruptedError(forKey: .admin, in: container, debugDescription: "Unable to decode MessageType")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .admin(let type):
            try container.encode(type, forKey: .admin)
        case .text:
            try container.encode("text", forKey: .text)
        case .photo:
            try container.encode("photo", forKey: .photo)
        case .video(let videoURL):
            try container.encode(videoURL, forKey: .videoURL)
        case .audio:
            try container.encode("audio", forKey: .audio)
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        switch self {
        case .admin(let type):
            hasher.combine("admin")
            hasher.combine(type)
        case .text:
            hasher.combine("text")
        case .photo:
            hasher.combine("photo")
        case .video(let videoURL):
            hasher.combine("video")
            hasher.combine(videoURL)
        case .audio:
            hasher.combine("audio")
        }
    }
}

