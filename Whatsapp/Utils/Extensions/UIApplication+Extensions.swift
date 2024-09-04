//
//  UIApplication+Extensions.swift
//  Whatsapp
//
//  Created by iCommunity app on 01/09/2024.
//

import Foundation
import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
