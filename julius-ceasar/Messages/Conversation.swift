//
//  DetailView.swift
//  test2
//
//  Created by Anton Khomyakov on 28.04.2021.
//
// DetailView

import SwiftUI
import Introspect

struct Conversation : View {
    
    // var conversationData: ConversationData
    
    var conversationService: ConversationService
    
    @State var textField : NSTextField?
    
    @State var messageText = ""

    //var id : String
    // private var chat: ChatInfo
    
//    init(conversationData: ConversationData) {
//        // self.homeData = homeData
//        // self.textField = nil
//        self.conversationData = conversationData
//    }
    
    init(chatId: Int64) {
        conversationService = ConversationData.getConversationService(chatId: chatId)
        
        
    }
    
    
    var body: some View {
        
        HStack {
            
            VStack{
                
                AllMessagesView(conversationService)
                
                Divider()
                
                HStack(spacing: 15) {
                    ScrollViewReader { reader in
                        ScrollView {
                            VStack {
                                Spacer()
                                TextField("Write a message...", text: $messageText, onCommit: {
                                    if !messageText.isEmpty {
                                        conversationService.sendTextMessage(messageText)
                                        messageText = ""
                                    }
                                })
                                .id(0)
                                .textFieldStyle(PlainTextFieldStyle())
                                .introspectTextField { textField in
                                    if self.textField == nil {
                                        self.textField = textField
                                        textField.becomeFirstResponder()
                                    }
                                }
                                Spacer()
                                .onChange(of: messageText) { _ in
                                    reader.scrollTo(0, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    Button(action: {textField?.becomeFirstResponder()}, label: {
                        Image(systemName: "paperplane.fill")
                            .resizable().scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.Blue)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(height: 32)
                .padding(.bottom, 10)
                .padding(.horizontal)
                
            }
             
        }
    }
}


extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

