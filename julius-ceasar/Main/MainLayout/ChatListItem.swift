//
//  RecentView.swift
//  test2
//
//  Created by Anton Khomyakov on 28.04.2021.
//

import SwiftUI


struct ChatListItem: View {
    
    @ObservedObject var chatData : ChatListData
    
    @ObservedObject var chatListService : ChatListService
    
    var index : Int64
    
    var unreadCount : Int = 0
    
    var title : String = ""
    
    var message : String = ""
    
    var date : String = ""
    
    var name: String = ""
    
    var isPersonal: Bool = false
    
    init(index: Int64, chatData: ChatListData, chatListService: ChatListService) {
        self.chatData = chatData
        self.chatListService = chatListService
        
        self.index = index
        let chat = chatListService.chats[index]
        self.unreadCount = chat?.unreadCount ?? 0
        self.title = chat?.title ?? ""
        self.message = chat?.lastMessage?.text ?? ""
        
        if let user = chat?.lastMessage?.user,
           let info = ServiceLayer.instance.fileService.users[user] {
            self.name = info.name
        }
        
        self.date = dateForMessages(from: chat?.lastMessage?.date)
        self.isPersonal = chat?.isPersonal ?? false
        //self._selectedTab = selectedTab
    }
    
    var body: some View {
        
        HStack{
            UserImage(fileService: ServiceLayer.instance.fileService,
                      chatId: index,
                      userId: nil,
                      name: title,
                      size: NSSize(width: 50, height: 50))
            
            VStack(spacing: 0){
                
                HStack{
                    
                    VStack(alignment: .leading, spacing: 0, content: {
                        Text(title)
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .lineLimit(1 + (isPersonal ? 1 : 0))
                        
                        if (!isPersonal) {
                            Text(name)
                                .fontWeight(.medium)
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                        
                        Text(message)
                            .lineLimit(1)
                        Spacer()
                    })
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    VStack (alignment: .trailing, spacing:0, content: {
                        Text(date)
                            .frame(alignment:.top)
                            .font(.system(size: 12))
                        Spacer()
                        Text(String(unreadCount))
                            //.border(Color.red)
                            .font(.system(size: 11))
                            .frame(minWidth: 12)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .foregroundColor(chatData.selectedChat != index ? .white: .Blue)
                            .background(chatData.selectedChat != index ? Color.Blue: Color.white)
                            .clipShape(Capsule())
                        .isHidden(unreadCount == 0)
                        Spacer()
                    })
                    .padding(.vertical, 20)
                }
                .frame(height:70)
                .padding(.trailing, 7)
                Divider()
            }.frame(alignment:.top)
            
        }
        .padding(.leading, 12)
    }
    
}





