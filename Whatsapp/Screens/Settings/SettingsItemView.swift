//
//  SettingsItemView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct SettingsItemView: View {
    let item: SettingsItem
    var body: some View {
        HStack {
            iconImageView()
                .frame(width: 30, height: 30)
                .foregroundStyle(.white)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            Text(item.title)
                .font(.system(size: 18))
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func iconImageView() -> some View {
        switch item.imageType {
        case .systemImage:
            Image(systemName: item.imageName)
                .bold()
                .font(.callout)
        case .assetImage:
            Image(item.imageName)
                .renderingMode(.template)
        }
    }
}

#Preview {
    SettingsItemView(item: .encryption)
}
