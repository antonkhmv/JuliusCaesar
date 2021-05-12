//
//  AllChatsView.swift
//  test2
//
//  Created by Anton Khomyakov on 28.04.2021.
//

import SwiftUI

struct MainViewWrapper : View {
    let chatData : ChatListData
    let windowsData: WindowsData
    let chatListService = ServiceLayer.instance.chatListService
    let parent: AppDelegate
    
    init(parent: AppDelegate) {
        self.parent = parent
        self.chatData = ChatListData(parent: parent)
        self.windowsData = WindowsData(parent: parent)
        try? chatListService.getChatList(limit: 50)
    }
    
    var body: some View {
        MainView(parent: parent)
            .environmentObject(chatData)
            .environmentObject(chatListService)
            .environmentObject(windowsData)
            .frame(minWidth: 700, idealWidth: 800, maxWidth: .infinity,
                   minHeight: 400, idealHeight: 500, maxHeight: .infinity)
    }
}

struct Header: View {
    @Binding var selectedTab: MainView.Tab
    @EnvironmentObject var chatData: ChatListData
    @EnvironmentObject var windowsData: WindowsData
    
    var body: some View {
        HStack {
            Spacer()
            switch (selectedTab) {
            case .chats:
                Button(action: {
                    windowsData.createNewWindow(chatId: chatData.selectedChat!)
                    selectedTab = .windows
                }) {
                    Text("New window with this chat")
                    Image(systemName:"plus")
                }
                .disabled(chatData.selectedChat == nil)
                .padding(.trailing, 10)
                .frame(height: 50)
            case .settings:
                EmptyView()
            case .windows:
                Button(action: {
                    windowsData.addChat(chatId: chatData.selectedChat!)
                }) {
                    Text("Add chat to selected window")
                    Image(systemName:"plus")
                }
                .disabled(chatData.selectedChat == nil
                    || windowsData.selectedWindow == nil
                    || windowsData.windows[windowsData.selectedWindow!]
                            .chatIds.contains(chatData.selectedChat!)
                    || windowsData.windows[windowsData.selectedWindow!].chatIds.count >= 6)
                .padding(.trailing, 10)
                .frame(height: 50)
            }
        } // HStack
    }
}

struct MainView: View {
    @EnvironmentObject var chatData : ChatListData
    @EnvironmentObject var windowsData : ChatListData
    @EnvironmentObject var chatListService : ChatListService
    
    @State private var leftWidth: CGFloat = 350
    @State private var minRightWidth: CGFloat = 400
    @State private var minLeftWidth: CGFloat = 300
    
    let parent: AppDelegate
    
    func getLeftWidth(_ proxy: GeometryProxy) -> CGFloat  {
        let size = proxy.size.width - minRightWidth - 2
        
        if size < leftWidth {
            DispatchQueue.global(qos: .userInitiated).async {
                leftWidth = size
            }
        }
        return leftWidth
    }
    
    func getRightWidth(_ proxy: GeometryProxy) -> CGFloat  {
        return proxy.size.width - leftWidth - 2
    }
    
    enum Tab {
        case settings
        case chats
        case windows
    }
    
    @State private var selectedTab: Tab = .chats
        
    var body: some View {
    GeometryReader { geometry in
        HStack (spacing: 0) {
            // switch
            
            VStack (spacing:0) {
                Header(selectedTab: $selectedTab)
                    .environmentObject(chatData)
                    .environmentObject(windowsData)
                
                switch (selectedTab) {
                case .settings:
                    Settings(parent: parent)
                    
                case .chats, .windows:
                    AllChatsView(selectedTab: $selectedTab)
                        .environmentObject(chatData)
                        .environmentObject(chatListService)
                }
                
                Divider()
                
                Footer(selectedTab: $selectedTab)
            } // VStack
            .frame(width: getLeftWidth(geometry))
            
            HSlideableDivider(getLeftWidth: { getLeftWidth(geometry) },
                              getRightWidth: { getRightWidth(geometry) },
                              widthChanged: { left, _ in leftWidth = left },
                              minLeftWidth: minLeftWidth,
                              minRightWidth: minRightWidth)
            
            switch (selectedTab) {
            case .chats, .settings:
                ConversationWrapper(selectedChat: $chatData.selectedChat)
                    .frame(width: getRightWidth(geometry))
            case .windows:
                Windows()
                    .environmentObject(windowsData)
                    .frame(width: getRightWidth(geometry))
            }
        }//HStack
        
        }//GeoReader
    }
    
    
}

