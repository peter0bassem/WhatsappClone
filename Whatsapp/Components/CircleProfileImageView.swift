//
//  CircleProfileImageView.swift
//  Whatsapp
//
//  Created by iCommunity app on 27/08/2024.
//

import SwiftUI
import Kingfisher

struct CircleProfileImageView: View {
    let profileImageUrl: String?
    let size: Size
    let fallbackImage: FallbackImage
    
    init(profileImageUrl: String? = nil, size: Size) {
        self.profileImageUrl = profileImageUrl
        self.size = size
        self.fallbackImage = .directChannelIcon
    }
    
    init(channel: Channel, size: Size) async {
        self.profileImageUrl = await channel.coverImageUrl
        self.size = size
        self.fallbackImage = FallbackImage(for: Int(channel.membersCount ?? 0))
    }
    
    var body: some View {
        if let profileImageUrl = profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            placeholderImageView()
        }
    }
    
    private func placeholderImageView() -> some View {
        Image(systemName: fallbackImage.rawValue)
            .resizable()
            .scaledToFit()
            .imageScale(.large)
            .foregroundStyle(Color.placeholder)
            .frame(width: size.dimension, height: size.dimension)
            .background(Color.white)
            .clipShape(Circle())
    }
}

extension CircleProfileImageView {
    enum Size {
        case mini, xSmall, small, medium, large, xLarge
        case custom(CGFloat)
        
        var dimension: CGFloat {
            switch self {
            case .mini:
                return 30
            case .xSmall:
                return 40
            case .small:
                return 50
            case .medium:
                return 64
            case .large:
                return 80
            case .xLarge:
                return 120
            case .custom(let dimen):
                return dimen
            }
        }
    }
    
    enum FallbackImage: String {
        case directChannelIcon = "person.circle.fill"
        case groupChatIcon = "person.2.circle.fill"
        
        init(for membersCount: Int) {
            switch membersCount {
            case 2: self = .directChannelIcon
            default: self = .groupChatIcon
            }
        }
    }
}

#Preview {
    CircleProfileImageView(profileImageUrl: nil, size: .large)
}
