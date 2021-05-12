//
//  MessageView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 01.05.2021.
//


import SwiftUI

struct AllMessagesView: View {
     
    @State private var topReached = false
    //@Binding private var listId: UUID
    
    @ObservedObject var conversationService: ConversationService
    
    init(_ conversationService: ConversationService) {
        self.conversationService = conversationService
    }
    
    @State var offset = CGFloat.zero

    var body: some View {
        ScrollView (.vertical) {
            if conversationService.listId != nil {
                LazyVStack(spacing:0) {
                        ForEach (conversationService.messages, id: \.uuid) { message in 
                            MessageCardView(conversationService: conversationService,
                                        fileService: ServiceLayer.instance.fileService,
                                        message: message)
                                        .padding(.vertical, 0)
                            .onAppear() {
                                if conversationService.messages.count > 0 {
                                    if conversationService.messages[conversationService.messages.count-1].id == message.id {
                                        conversationService.getMessages(fromMessageId: message.id, limit: 50)
                                    }
                                }
                                //print(
                                if !message.isOutgoing {
                                    conversationService.readMessage(message.id)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .rotationEffect(.radians(.pi))
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                        } // foreach
                        .id(conversationService.listId)
                    } // Vstack
                //.id(conversationService.listId)
            }
            else {
                Color.clear.onAppear() {
                    conversationService.listId = UUID() 
                }
            }
        } // scroll view
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .rotationEffect(.radians(.pi))
        .scaleEffect(x: -1, y: 1, anchor: .center)
        
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
