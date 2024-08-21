//
//  MessageListView.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageListViewController
    
    func makeUIViewController(context: Context) -> MessageListViewController {
        return MessageListViewController(nibName: nil, bundle: nil)
    }
    
    func updateUIViewController(_ uiViewController: MessageListViewController, context: Context) {
        
    }
    
    
}

#Preview {
    MessageListView()
}
