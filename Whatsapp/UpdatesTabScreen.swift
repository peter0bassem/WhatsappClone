//
//  UpdatesTabScreen.swift
//  Whatsapp
//
//  Created by iCommunity app on 20/08/2024.
//

import SwiftUI

struct UpdatesTabScreen: View {
    @State private var searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                Section {
                    StatusSectionHeaderView()
                        .listRowBackground(Color.clear)
                    StatusSection()
                } header: {
                    Text("Status")
                        .bold()
                        .font(.title3)
                        .textCase(nil)
                        .foregroundStyle(.whatsAppBlack)
                }
                .listRowSeparator(.hidden)
                
                Section {
                    RecentUpdatesItemView()
                } header: {
                    Text("Recent Updates")
                }
                
                Section {
                    ChannelListView()
                } header: {
                    channelSectionHeader()
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.grouped)
            .navigationTitle("Updates")
            .searchable(text: $searchText)
        }
    }
    
    private func channelSectionHeader() -> some View {
        HStack {
            Text("Channels")
                .bold()
                .font(.title3)
                .textCase(nil)
                .foregroundStyle(.whatsAppBlack)
            Spacer()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "plus")
                    .padding(7)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            })
        }
    }
}

private struct StatusSectionHeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.dashed")
                .foregroundStyle(.blue)
                .imageScale(.large)
            
            (
                Text("Use Status to share photos, text, and videos that disappear in 24 hours.")
                +
                Text(" ")
                +
                Text("Status Privavacy")
                    .foregroundStyle(.blue)
                    .bold()
            )
            
            Image(systemName: "xmark")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct StatusSection: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: UpdatesTabScreen.Constant.imageDimension, height: UpdatesTabScreen.Constant.imageDimension)
            
            VStack(alignment: .leading) {
                Text("My Status")
                    .font(.callout)
                    .bold()
                Text("Add to my status")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
            Spacer()
            cameraButton()
            pencilButton()
        }
    }
    
    private func cameraButton() -> some View {
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            Image(systemName: "camera.fill")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        })
    }
    
    private func pencilButton() -> some View {
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            Image(systemName: "pencil")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        })
    }
}

private struct RecentUpdatesItemView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: UpdatesTabScreen.Constant.imageDimension, height: UpdatesTabScreen.Constant.imageDimension)
            
            VStack(alignment: .leading) {
                Text("Joseph Smith")
                    .font(.callout)
                    .bold()
                Text("1h ago")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
        }
    }
}

private struct ChannelListView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stay updated on topics that matter to you. Find channels to follow below.")
                .foregroundStyle(.gray)
                .font(.callout)
//                .padding(.horizontal)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<5) { _ in
                        ChannelItemView()
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Button("Explore more") {
                
            }
            .tint(.blue)
            .bold()
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
            .padding(.vertical)
        }
    }
}

private struct ChannelItemView: View {
    var body: some View {
        VStack {
            Circle()
                .frame(width: UpdatesTabScreen.Constant.imageDimension, height: UpdatesTabScreen.Constant.imageDimension)
            
            Text("Read Madrid C.F")
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Follow")
                    .bold()
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            })
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

extension UpdatesTabScreen {
    enum Constant {
        static let imageDimension: CGFloat = 55
    }
}

#Preview {
    UpdatesTabScreen()
}
