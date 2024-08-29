//
//  MediaPickerItem_Types.swift
//  Whatsapp
//
//  Created by iCommunity app on 28/08/2024.
//

import SwiftUI

struct VideoPickerTranferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
            return .init(exportingFile.url)
        } importing: { receivedTransferredFile in
            let originalFile = receivedTransferredFile.file
            let uniqueFileName = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: originalFile, to: copiedFile)
            return .init(url: copiedFile)
        }
    }
}

struct MediaAttachment: Identifiable {
    let id: String?
    let type: MediaAttachmentType
    
    var thumbnail: UIImage {
        switch type {
        case .photo(let imageAttachment):
            return imageAttachment
        case .video(let thumbnailImage, _):
            return thumbnailImage
        case .audio:
            return UIImage()
        }
    }
    
    var fileURL: URL? {
        switch type {
        case .photo(_):
            return nil
        case .video(_, let videoURL):
            return videoURL
        case .audio(let fileURL, _):
            return fileURL
        }
    }
}

enum MediaAttachmentType: Equatable{
    case photo(imageAttachment: UIImage)
    case video(thumbnailImage: UIImage, videoURL: URL)
    case audio(audioURL: URL, duration: TimeInterval)
    
    static func == (lhs: MediaAttachmentType, rhs: MediaAttachmentType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo), (.video, .video), (.audio, .audio):
            return true
        default: return false
        }
    }
}
