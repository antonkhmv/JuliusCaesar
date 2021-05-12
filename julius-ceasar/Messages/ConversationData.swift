//
//  ConversationData.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 30.04.2021.
//

import SwiftUI
import Combine


class ConversationData  {
    //private var conversationService : ConversationService
    static var services = [Int64 : ConversationService]()
    //var chatId:Int64
    
    static func getConversationService(chatId: Int64) -> ConversationService {
        if let service = Self.services[chatId] {
            //service.notifyChanged()
            return service
        }
        
        let conversationService = ConversationService(tdApi: ServiceLayer.instance.telegramService.api,
            chatId: chatId)
        ServiceLayer.instance.telegramService.add(listener: conversationService)
        // conversationService.delegate = self
        conversationService.getMessages(limit: 30)
        Self.services[chatId] = conversationService
         
        return conversationService
    }
    
    deinit {
        // ServiceLayer.instance.telegramService.remove(listener: self.conversationService)
    }
    
    
}

//        anyCancellable = conversationService.objectWillChange.sink { [weak self] _ in
//            self?.objectWillChange.send()
//        }
   
