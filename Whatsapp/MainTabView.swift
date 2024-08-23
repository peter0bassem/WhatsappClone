//
//  MainTabView.swift
//  Whatsapp
//
//  Created by iCommunity app on 19/08/2024.
//

import SwiftUI
import SwiftUIIntrospect

struct MainTabView: View {
    
    var body: some View {
        TabView {
            UpdatesTabScreen()
                .tabItem {
                    Image(systemName: Tab.updates.icon)
                    Text(Tab.updates.title)
                }
            
            CallTabScreen()
                .tabItem {
                    Image(systemName: Tab.calls.icon)
                    Text(Tab.calls.title)
                }
            
            CommunityTabScreen()
                .tabItem {
                    Image(systemName: Tab.communities.icon)
                    Text(Tab.communities.title)
                }
            
            ChannelTabScreen()
                .tabItem {
                    Image(systemName: Tab.chats.icon)
                    Text(Tab.chats.title)
                }
            
            SettingsTabScreen()
                .tabItem {
                    Image(systemName: Tab.settings.icon)
                    Text(Tab.settings.title)
                }
        }
        .introspect(.tabView, on: .iOS(.v17)) { tabBar in
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            tabBar.tabBar.standardAppearance = appearance
            tabBar.tabBar.scrollEdgeAppearance = appearance
        }
    }
}

private extension MainTabView {
    private func placeholderItemView(_ title: String) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(0..<120, id: \.self) { _ in
                    Text(title)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.green)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    enum Tab: String {
        case updates, calls, communities, chats, settings
        
        fileprivate var title: String {
            rawValue.capitalized
        }
        
        fileprivate var icon: String {
            switch self {
            case .updates: return "circle.dashed.inset.fill"
            case .calls: return "phone"
            case .communities: return "person.3"
            case .chats: return "message"
            case .settings: return "gear"
            }
        }
    }
}

#Preview {
    MainTabView()
}
