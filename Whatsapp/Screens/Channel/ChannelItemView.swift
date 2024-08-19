//
//  ChannelItemView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct ChannelItemView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 3) {
                titleView()
                lastMessagePreview()
            }
        }
    }
    
    private func titleView() -> some View {
        HStack {
            Text("Username")
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text("5:50 pm")
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text("Last message.")
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView()
}
