//
//  ChatRoomScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct ChatRoomScreen: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<12) { _ in
                    BubbleTextView(item: .sentPlaceholder)
                    BubbleTextView(item: .receivedPlaceholder)
                }
            }
            .padding(.horizontal, 10)
        }
        .background(Color.gray.opacity(0.1))
        .toolbar {
            leadingNavItems()
            trailingNavItems()
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            TextInputAreaView()
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

private extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Circle()
                    .frame(width: 35, height: 35)
                VStack(alignment: .leading) {
                    Text("Username")
                        .bold()
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItems() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "video")
            })
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "phone")
            })
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen()
    }
}
