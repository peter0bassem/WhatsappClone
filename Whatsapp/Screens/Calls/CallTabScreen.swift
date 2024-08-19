//
//  CallTabScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct CallTabScreen: View {
    @State private var searchText: String = ""
    @State private var callHistorySelection: CallHistory = .all
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CallLinkSectionview()
                }
                
                Section {
                    ForEach(0..<12) { _ in
                        RecentlyCallItemView()
                    }
                } header: {
                    Text("Recent")
                        .bold()
                        .font(.title3)
                        .textCase(nil)
                        .foregroundStyle(.whatsAppBlack)
                }
            }
            .navigationTitle("Calls")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                principleNavBarItem()
                trailingNavItem()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                
            } label: {
                Text("Edit")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "phone.arrow.up.right")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func principleNavBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $callHistorySelection) {
                ForEach(CallHistory.allCases) { item in
                    Text(item.rawValue.capitalized)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
        }
    }
    
    private enum CallHistory: String, CaseIterable, Identifiable {
        case all, missed
        
        var id: String {
            return rawValue
        }
    }
}

private struct CallLinkSectionview: View {
    var body: some View {
        HStack {
            Image(systemName: "link")
                .foregroundStyle(.blue)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text("Create Call Link")
                    .foregroundStyle(.blue)
                Text("Share a link for your Whatsapp call")
                    .foregroundStyle(.gray)
                    .font(.caption)
                    
            }
        }
    }
}

private struct RecentlyCallItemView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 45, height: 45)
            
            recentCallsTextView()
            Spacer()
            Text("Yesterday")
                .foregroundStyle(.gray)
                .font(.system(size: 16))
            
            Image(systemName: "info.circle")
            
        }
    }
    
    private func recentCallsTextView() -> some View {
        VStack(alignment: .leading) {
            Text("John Smith")
            HStack {
                Image(systemName: "phone.arrow.up.right")
                Text("Outgoing")
            }
            .font(.system(size: 14))
            .foregroundStyle(.gray)
        }
    }
}

#Preview {
    CallTabScreen()
}
