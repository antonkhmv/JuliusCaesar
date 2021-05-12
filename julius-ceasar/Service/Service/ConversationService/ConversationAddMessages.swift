//
//  ConversationAddMessages.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 05.05.2021.
//

import Foundation
import TdlibKit

extension ConversationService {
        
    func getMessages(fromMessageId: Int64 = 0, limit: Int = 50, offset: Int = 0)
    {
        if !self.finishedLoading {
            return
        }
        self.messageCount = 0
        self.finishedLoading = false
        getMessagesHelper(fromMessageId: fromMessageId,
                          limit: limit, offset: offset)
    }

    private func getMessagesHelper(fromMessageId: Int64 = 0, limit: Int = 50, offset: Int = 0) {
       // var hello = 1
        
        try? api.getChatHistory(
            chatId: chatId,
            fromMessageId: fromMessageId,
            limit: limit - self.messageCount,
            offset: offset,
            onlyLocal: false,
            completion: { [weak self] result in
                //2;
                guard let self = self else { return }
                
                if case .failure(let error) = result {
                    self.onError(error)
                    return
                }
                
                if let msgs = try? result.get().messages {
                    //let textMsgs = messages.map { TextMessage($0) }
                    self.addMessages(msgs) {
                        self.messageCount += msgs.count
                        if !msgs.isEmpty && self.messageCount < limit  {
                            self.getMessagesHelper(fromMessageId: self.messages.last!.id,
                                             limit: limit)
                            return
                        }
                        else {
                            self.forceUpdate()
                        }
                        
                        if !msgs.isEmpty {
                            self.finishedLoading = true 
                        }
                        //self.forceUpdate()
                    }
                }
                
            }
        )
    }
    
    private func add(_ msg: TextMessage, _ user: UserInfo, at: Int?) {
        
        let service = ServiceLayer.instance.fileService
        
        if msg.senderUserId != 0 {
            if service.files[user.id] == nil {
                service.downloadProfilePicture(user, completion: {
                    [weak self] result in
                    guard let self = self else {return}
                    self.forceUpdate()
                })
            }
        }
        else if msg.senderChatId != 0{
            if service.chatPhotos[msg.senderChatId] == nil,
            let chatInfo = ServiceLayer.instance.chatListService.chats[chatId] {
                service.downloadChatPhoto(chatInfo, completion: {
                    [weak self] result in
                    guard let self = self else {return}
                    self.forceUpdate()
                })
            }
        }
        
        if at != nil {
            self.messages.insert(msg, at:at!)
        }
        
    }
    
    internal func addMessage(_ message: Message, at: Int?, completion: @escaping (TextMessage) -> () ) {
        
        var msg = TextMessage(message)
        let service =  ServiceLayer.instance.fileService
        
        if let user = service.users[msg.senderUserId] {
            msg.user = user.id
            add(msg, user, at: at)
            completion(msg)
        }
        else {
            service.getUser(msg.senderUserId, completion: {
                [weak self] result in
                guard let self = self else {return}
                msg.user = result.id
                self.add(msg, result, at: at)
                completion(msg)
            })
        }
    }

    internal func addMessages(_ messages: [Message], completion: @escaping ()->()) {
        guard messages.count > 0 else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        var count = messages.count
        group.enter()
        
        var buffer = [TextMessage?](repeating: nil, count: messages.count)
        
        DispatchQueue.global(qos: .userInitiated).async {
            for (i, message) in messages.enumerated() {
                self.addMessage(message, at: nil) { msg in
                    buffer[i] = msg
                    count -= 1
                    if count == 0 {
                        group.leave()
                    }
                }
            }
        }
        
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if var lastMsg = self.messages.last {
                lastMsg.isDateShown = !Calendar.current.isDate(
                    buffer[0]!.date,
                    inSameDayAs: lastMsg.date)
            }
            
            for i in 1..<buffer.count {
                buffer[i-1]!.isDateShown = !Calendar.current.isDate(
                    buffer[i]!.date,
                    inSameDayAs: buffer[i-1]!.date)
            }
            
            self.messages.append(contentsOf: buffer.map {$0!})
            completion()
        }
         
        //self.objectWillChange.send()
    }
}
