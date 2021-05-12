//
//  Updates.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 05.05.2021.
//

import Foundation
import TdlibKit
import SwiftUI

extension ConversationService {
    func onError(_ error: Swift.Error) {
        print("error")
    }

    func forceUpdate() {
        listId = nil
        //visibleMessages = messages.suffix(60)
    }
    
    func onUpdate(_ update: Update) {
        switch update {
        case .updateNewMessage(let newMsg):
            guard newMsg.message.chatId == chatId else { return }
            //messages.append(msg)
            addMessage(newMsg.message, at:0) { [weak self] _ in
                guard let self = self else {return}
                self.readMessage(newMsg.message.id)
                if !newMsg.message.isOutgoing {
                    ServiceLayer.instance.chatListService.onUpdate(
                        Update.updateChatReadInbox(UpdateChatReadInbox(
                            chatId: self.chatId,
                            lastReadInboxMessageId: newMsg.message.id,
                            unreadCount: 0))
                    )
                }
                self.forceUpdate()
            }
            
            
        case .updateMessageContent(let upd):
            guard upd.chatId == chatId else { return }
            if let idx = messages.firstIndex(where: { $0.id == upd.messageId }) {
                var msg = messages[idx]
                msg.updateContent(upd.newContent)
                messages[idx] = msg
            }
            forceUpdate()
            //self.objectWillChange.send()
        
        case .updateDeleteMessages(let upd):
            if  !self.chatIsOpen && !upd.fromCache && upd.chatId == chatId {
                upd.messageIds.forEach { messageId in
                    if let idx = messages.firstIndex(where: { $0.id == messageId }) {
                        messages.remove(at: idx)
                    }
                }
                finishedLoading = true
                forceUpdate()
            }
            if upd.chatId != chatId {
                let newUpd = UpdateDeleteMessages(chatId: upd.chatId,
                                                  fromCache: false,
                                                  isPermanent: upd.isPermanent,
                                                  messageIds: upd.messageIds)
                
                ConversationData.getConversationService(chatId: upd.chatId)
                    .onUpdate(Update.updateDeleteMessages(newUpd))
                
                ConversationData.getConversationService(chatId: upd.chatId)
                    .finishedLoading = true
            }
        case .updateMessageEdited:
            break
            
        default:
            break
        }
        
    }
}
