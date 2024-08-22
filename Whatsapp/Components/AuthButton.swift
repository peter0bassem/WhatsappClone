//
//  AuthButton.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI

struct AuthButton: View {
    let title: String
    var onTap: (() -> Void) = { }
    @Environment(\.isEnabled) private var isEnabled
    
    private var backgroundColor: Color {
        isEnabled ? .white : .white.opacity(0.3)
    }
    
    private var textColor: Color {
        isEnabled ? .green : .white
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text(title)
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .green.opacity(0.2), radius: 10)
            .padding(.horizontal, 16)
        }

    }
}

#Preview {
    ZStack {
        Color.teal
        AuthButton(title: "Login")
    }
}
