//
//  FirebaseHelper.swift
//  Whatsapp
//
//  Created by iCommunity app on 30/08/2024.
//

import Foundation
import UIKit
import FirebaseStorage
import Combine

enum UploadError: Error {
    case failedToCreateImageData
    case failedToUploadImage(_ description: String)
    case failedToDownloadURL(_ desctiption: String)
    case failedToUploadFile(_ description: String)
}

extension UploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToCreateImageData:
            return nil
        case .failedToUploadImage(let description):
            return description
        case .failedToDownloadURL(let description):
            return description
        case .failedToUploadFile(let description):
            return description
        }
    }
}

class FirebaseHelper {
    
    typealias UploadCompletion = ((Result<URL, Error>) -> Void)
    typealias ProgressHandler = ((Double) -> Void)
    
    // MARK: Aync Functions
    static func uploadImage(
        image: UIImage,
        for type: UploadType
    ) async throws -> (URL, Double) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw UploadError.failedToCreateImageData
        }

        let storageRef = type.filePath
        let uploadTask = storageRef.putData(imageData)

        return try await withCheckedThrowingContinuation { continuation in
            var progress: Double = 0.0

            uploadTask.observe(.progress) { snapshot in
                progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                // Handle progress updates if needed
                print("Upload progress: \(progress * 100)%")
            }

            uploadTask.observe(.success) { _ in
                storageRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: UploadError.failedToDownloadURL(error.localizedDescription))
                    } else if let url = url {
                        continuation.resume(returning: (url, progress))
                    }
                }
            }

            uploadTask.observe(.failure) { snapshot in
                continuation.resume(throwing: UploadError.failedToUploadImage(snapshot.error?.localizedDescription ?? ""))
            }
        }
    }
    
    static func uploadFile(
        for type: UploadType,
        fileURL: URL
    ) async throws -> (URL, Double) {
        let storageRef = type.filePath
        let uploadTask = storageRef.putFile(from: fileURL)

        return try await withCheckedThrowingContinuation { continuation in
            var progress: Double = 0.0

            uploadTask.observe(.progress) { snapshot in
                progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                // Handle progress updates if needed
                print("Upload progress: \(progress * 100)%")
            }

            uploadTask.observe(.success) { _ in
                storageRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: UploadError.failedToDownloadURL(error.localizedDescription))
                    } else if let url = url {
                        continuation.resume(returning: (url, progress))
                    }
                }
            }

            uploadTask.observe(.failure) { snapshot in
                continuation.resume(throwing: UploadError.failedToUploadFile(snapshot.error?.localizedDescription ?? ""))
            }
        }
    }

    // MARK: Completion Handler
    static func uploadImage(
        image: UIImage,
        for type: UploadType,
        completion: @escaping UploadCompletion,
        progressHandler: @escaping ProgressHandler
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = type.filePath
        let uploadTask = storageRef.putData(imageData) { _, error in
            if let error = error {
                print("Failed to Upload Image to Storage: \(error.localizedDescription)")
                completion(.failure(UploadError.failedToUploadImage(error.localizedDescription)))
            }
            
            storageRef.downloadURL(completion: completion)
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progressHandler(percentComplete)
        }
    }
    
    
    /// This function is going to be responsible for uploading both video and audio files
    static func uploadFile(
        for type: UploadType,
        fileURL: URL,
        completion: @escaping UploadCompletion,
        progressHandler: @escaping ProgressHandler
    ) {
        let storageRef = type.filePath
        let uploadTask = storageRef.putFile(from: fileURL) { _, error in
            if let error = error {
                print("Failed to Upload File to Storage: \(error.localizedDescription)")
                completion(.failure(UploadError.failedToUploadImage(error.localizedDescription)))
            }
            
            storageRef.downloadURL(completion: completion)
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progressHandler(percentComplete)
        }
    }
}

enum UploadType {
    case profile
    case photoMessage
    case videoMessage
    case voiceMessage
    
    var filePath: StorageReference {
        let fileName = UUID().uuidString
        switch self {
        case .profile:
            return FirebaseReferenceConstants.StorageReference.child("profile_image_urls").child(fileName)
        case .photoMessage:
            return FirebaseReferenceConstants.StorageReference.child("photo_messages").child(fileName)
        case .videoMessage:
            return FirebaseReferenceConstants.StorageReference.child("video_messages").child(fileName)
        case .voiceMessage:
            return FirebaseReferenceConstants.StorageReference.child("voice_messages").child(fileName)
        }
    }
}

struct MessageUploadRequest {
    let channel: Channel
    let text: String
    let type: MessageType
    let attachment: MediaAttachment
    var thmbnailURL: String?
    var videoURL: String?
    var sender: User
    var audioURL: String?
    var audioDuration: TimeInterval?
    
    var ownerId: String {
        sender.uid
    }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo || type == .video(videoURL: nil) else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo || type == .video(videoURL: nil) else { return nil }
        return attachment.thumbnail.size.height
    }
}
