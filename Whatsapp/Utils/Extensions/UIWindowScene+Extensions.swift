//
//  UIWindowScene+Extensions.swift
//  Whatsapp
//
//  Created by iCommunity app on 03/09/2024.
//

import Foundation
import UIKit

extension UIWindowScene {
    static var current: UIWindowScene? {
        UIApplication.shared.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
    }
    
    var screenHeight: CGFloat {
        UIWindowScene.current?.screen.bounds.height ?? 0.0
    }
    
    var screenWidth: CGFloat {
        UIWindowScene.current?.screen.bounds.width ?? 0.0
    }
}
