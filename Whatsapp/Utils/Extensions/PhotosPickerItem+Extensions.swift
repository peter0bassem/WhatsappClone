//
//  PhotosPickerItem+Extensions.swift
//  Whatsapp
//
//  Created by iCommunity app on 28/08/2024.
//

import Foundation
import PhotosUI
import SwiftUI

extension PhotosPickerItem {
    var isVideo: Bool {
        let videoUTTypes: [UTType] = [.avi, .video, .mpeg2Video, .mpeg4Movie, .movie, .quickTimeMovie, .audiovisualContent, .mpeg, .appleProtectedMPEG4Video]
        return videoUTTypes.contains(where: supportedContentTypes.contains(_:))
    }
}

/*
 unable to spawn process '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-stat-cache' (Resource temporarily unavailable)
 */
