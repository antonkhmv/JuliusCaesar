//
//  MultiWindow.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 10.05.2021.
//

import SwiftUI

struct ConversationCell: View {
    @EnvironmentObject var windowsData : WindowsData
    
    var chatId: Int64
    
    var id: Int
    
    var chatListService = ServiceLayer.instance.chatListService
    
    @State private var selectedService: ConversationService?
     
    var body: some View {
        VStack(spacing:0) {
            HStack {
                Button(action: {
                    windowsData.removeChat(chatId, id)
                    if let service = ConversationData.services[chatId] {
                        service.closeChat()
                    }
                }) {
                    Image(systemName: "xmark").foregroundColor(.red)
                }
                .padding(.leading, 15)
                Spacer()
                Text(chatListService.chats[chatId]!.title)
                    .font(.title2)
                    .lineLimit(1)
                Spacer()
            }
            .frame( maxWidth: .infinity, minHeight: 40, alignment:.leading)
            .background(Color.primary.opacity(0.15))
            
            Divider()
            
            Conversation(chatId: chatId)
            .onAppear() {
                selectedService = ConversationData.getConversationService(chatId: chatId)
                selectedService?.openChat()
            }
        }
    }
}

struct MultiWindow: View {
    
    @EnvironmentObject var windowsData : WindowsData
    @EnvironmentObject var chatData: ChatListData
    
    var id: Int
    
    @Binding var window: Window
    
    var parent: AppDelegate
    
    @State var isPresented = false
    
    @ViewBuilder func getTable() -> some View {
        let cell = window.chatIds.indices.map {
            ConversationCell(chatId: window.chatIds[$0], id: id)
        }
        
        switch window.chatIds.count {
        case 1: cell[0] 
        case 2: CustomHSplitView(content: cell, minWidth: 300)
            .frame(minWidth:605, minHeight:300)
        case 3: CustomHSplitView(content: cell, minWidth: 300)
            .frame(minWidth:910, minHeight:605)
            
        case 4: CustomVSplitView(content: [
                    CustomHSplitView(content: [cell[0], cell[1]], minWidth: 300),
                    CustomHSplitView(content: [cell[2], cell[3]], minWidth: 300),
                ], minHeight: 300).frame(minWidth:605, minHeight:605)
            
        case 5: CustomVSplitView(content: [
                    CustomHSplitView(content: [cell[0], cell[1], cell[2]], minWidth: 300),
                    CustomHSplitView(content: [cell[3], cell[4]], minWidth: 300),
                ], minHeight: 300).frame(minWidth:910, minHeight:605)
        case 6:  CustomVSplitView(content: [
                    CustomHSplitView(content: [cell[0], cell[1], cell[2]], minWidth: 300),
                    CustomHSplitView(content: [cell[3], cell[4], cell[5]], minWidth: 300),
                ], minHeight: 300).frame(minWidth:910, minHeight:605)
                
        default:
            Text("Empty")
                .frame(maxWidth:.infinity, maxHeight:.infinity)
        }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { parent.setMain() } ) {
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                    Text("Back to main window")
                }

                Button(action: {
                    isPresented = true
                } ) {
                    Image(systemName: "plus")
                    Text("Add another chat")
                }
                .popover(isPresented: $isPresented) {
                    VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented = false
                        } ) {
                            Image(systemName: "xmark")
                            Text("close")
                        }
                        .foregroundColor(.red)
                        .padding()

                        Spacer()
                        Button(action: {
                            if let chatId = chatData.selectedChat {
                                window.chatIds.append(chatId)
                            }
                            isPresented = false
                        } ) {
                            Image(systemName: "plus")
                            Text("Add chat")
                        }
                            .disabled(chatData.selectedChat == nil
                                || window.chatIds.contains(chatData.selectedChat!)
                                || window.chatIds.count >= 6)
                        .padding()
                        Spacer()
                    }

                    AllChatsView(selectedTab: .constant(.windows))
                        .environmentObject(chatData)
                        .environmentObject(ServiceLayer.instance.chatListService)
                    }.frame(maxWidth: 400, maxHeight: 600)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .padding(.horizontal)
            .background(Color.primary.opacity(0.05))
            
            //Divider()
            
            self.getTable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear() {
            for chatId in window.chatIds {
                if let service = ConversationData.services[chatId] {
                    service.closeChat()
                }
            }
        }
    }
    
}

