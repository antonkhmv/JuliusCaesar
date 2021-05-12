//
//  Message.swift
//  test2
//
//  Created by Anton Khomyakov on 28.04.2021.
//

import SwiftUI

// Message Card View

struct MessageCardView: View {
    var conversationService : ConversationService
    var fileService : FileService
    
    var message: TextMessage
    
    @Environment(\.openURL) var openURL
    
    private var name : String?
    private var isNewDayCardShown: Bool
    
    init(conversationService : ConversationService, fileService : FileService, message: TextMessage) {
        self.conversationService = conversationService
        self.fileService = fileService
        self.message = message
        
        if let userId = message.user,
           let user = fileService.users[userId] {
            name = user.name
        }
        else {
            let chatId = message.chatId
            if let chat = ServiceLayer.instance.chatListService.chats[chatId] {
                name = chat.title
            }
        }
        
        isNewDayCardShown = message.isDateShown
        
        if conversationService.messages.count > 0 {
            if conversationService.messages[
                conversationService.messages.count-1].id == message.id {
            
            isNewDayCardShown = true
            }
        }
    }
     
    var body: some View {
        //var isProfilePhotoPresent = false
        
        VStack (spacing: 0){
            if isNewDayCardShown {
                Text(newDayCard(message.date))
                    .padding(.vertical, 10)
            }
            
            HStack(spacing: 10){
                VStack (spacing: 0) {
                    UserImage(fileService: fileService,
                              chatId: nil,
                              userId: message.user,
                              name: name,
                              size: NSSize(width: 40, height: 40))
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Text(name ?? "Unknown")
                            .foregroundColor(.Blue)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment:.leading)
                        Spacer()
                        Text(dateToTime(from: message.date))
                            .padding(.trailing, 10)
                    }
                    //ZStack {
                    if message.photo != nil {
                        MessageImage(photo: message.photo!)
                            .frame(alignment: .leading)
                    }
                    if message.doc != nil {
                        DocumentView(doc: message.doc!)
                            .frame(alignment: .leading)
                    }
                    Text(message.text ?? "")
                        .foregroundColor(.primary)
                        .contextMenu {
                            VStack {
                                Button("Copy") {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.declareTypes([.string], owner: nil)
                                    pasteboard.setString(message.text ?? "", forType: .string)
                                }
                                if (message.links != nil) {
                                    ForEach (message.links!, id:\.self) { link in
                                        Button(link) {
                                            openURL(URL(string: link)!)
                                        }
                                    }
                                }
                                
                            }
                        }
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding(.trailing, 50)
                        .padding(.bottom, 10)
                    }//vstack
                }
            }//hstack
            .padding(.leading, 12)
    }
    
}

