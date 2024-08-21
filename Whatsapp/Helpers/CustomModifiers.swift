//
//  CustomModifiers.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import Foundation
import SwiftUI

private struct BubbleTailModifier: ViewModifier {
    var direction: MessageDirection
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: direction == .received ? .bottomLeading : .bottomTrailing) {
                BubbleTailView(messageDirection: direction)
            }
    }
}

extension View {
    func applyTail(direction: MessageDirection) -> some View {
        self.modifier(BubbleTailModifier(direction: direction))
    }
}
