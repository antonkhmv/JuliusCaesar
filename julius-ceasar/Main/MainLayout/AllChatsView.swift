//
//  AllChatsView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 02.05.2021.
//

import SwiftUI

struct AllChatsView: View {
    @EnvironmentObject var chatData : ChatListData
    
    @EnvironmentObject var chatListService : ChatListService
    
    @EnvironmentObject var windowsData : WindowsData
    
    @Binding var selectedTab : MainView.Tab
    
    var body: some View {
            ScrollView {
                VStack (spacing: 0) {
                    ForEach (chatListService.chatList, id: \.chatId) { order in
                        VStack (spacing: 0) {
                            ChatListItem(index: order.chatId,
                                         chatData: chatData,
                                         chatListService: chatListService)
                                
                                .background(chatData.selectedChat != nil
                                                && chatData.selectedChat! == order.chatId ?
                                                Color.Blue : Color.primary.opacity(0.001))
                            
                                .foregroundColor(chatData.selectedChat != nil
                                                    && chatData.selectedChat! == order.chatId ?
                                                    .white : .primary)
                            .contextMenu {
                                VStack {
                                    Button("New window with this chat") {
                                        windowsData.createNewWindow(chatId: order.chatId)
                                        selectedTab = .windows
                                    }
                                    
                                    Button("New window with this chat + open") {
                                        windowsData.createNewWindow(chatId: order.chatId)
                                        selectedTab = .windows
                                        windowsData.openWindow(0)
                                    }
                                    
                                    ForEach (windowsData.windows.indices) { id in
                                        Button("Add chat to " + windowsData.windows[id].name) {
                                            windowsData.addChat(id: id, chatId: order.chatId)
                                            }
                                        .disabled(windowsData.windows[id].chatIds.count >= 6 || windowsData.windows[id]
                                                    .chatIds.contains(order.chatId))
                                    }
                                    .id(UUID())
                                }
                                
                            }// context menu
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if chatData.selectedChat != order.chatId {
                                chatData.selectedChat = order.chatId
                            }
                        }
                    }
                    .id(chatListService.listId)
                }// Vstack
            
        }
    }
}

