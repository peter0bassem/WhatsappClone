//
//  URL+Extensions.swift
//  Whatsapp
//
//  Created by iCommunity app on 28/08/2024.
//

import Foundation
import AVFoundation
import SwiftUI

extension URL {
    func generateThumbnail() async throws -> UIImage? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        return try await withCheckedThrowingContinuation { continuation in
            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                if let cgImage = cgImage {
                    let thumbnailImage = UIImage(cgImage: cgImage)
                    continuation.resume(returning: thumbnailImage)
                } else {
                    continuation.resume(throwing: error ?? NSError(domain: "", code: 0))
                }
            }
        }
    }
}
