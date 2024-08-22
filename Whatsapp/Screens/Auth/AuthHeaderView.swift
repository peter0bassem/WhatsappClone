//
//  AuthHeaderView.swift
//  Whatsapp
//
//  Created by iCommunity app on 22/08/2024.
//

import SwiftUI

struct AuthHeaderView: View {
    var body: some View {
        HStack {
            Image(.whatsapp)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("WhatsApp")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    AuthHeaderView()
        .background(Color.gray)
}
