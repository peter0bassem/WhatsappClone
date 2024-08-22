//
//  WhatsappApp.swift
//  Whatsapp
//
//  Created by iCommunity app on 19/08/2024.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseManager.configureApp()
        return true
    }
}

@main
struct WhatsappApp: App {
    
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LoginScreen()
        }
    }
}
