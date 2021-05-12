import Foundation
import TdlibKit
import SwiftUI

class ConversationService: ObservableObject, UpdateListener {

    // MARK: - Private properties
    
    var messages: [TextMessage] = []
    
   // var visibleMessages: [TextMessage] = []
    
    @Published var listId: UUID?
    
    internal let api: TdApi
    internal var messageCount = 0
    
    internal var chatId: Int64
    // var chatInfo: ChatInfo
    var chatIsOpen: Bool
    
    internal var finishedLoading = true
    

    // @State var proxy : ScrollViewProxy?
    
    // MARK: - Public properties
    
    // weak var delegate: ConversationServiceDelegate?

    // MARK: - Init

    // var delegate : ConversationServiceDelegate
    
    init(tdApi: TdApi, chatId: Int64) {
        self.api = tdApi
        self.chatId = chatId
        self.chatIsOpen = true
        self.listId = UUID()
    }
    
    
    // MARK: - Public methods
    
    
    func sendTextMessage(_ message: String) {
        //let textMessage = NSRegularExpression
          //  .escapedPattern(for: message)
            //.replacingOccurrences(of: "-", with: "\\-")
        
        try? api.parseTextEntities(
                parseMode: .textParseModeHTML,
                text: message,
                completion: { [weak self] result in
                guard let self = self else { return }
                if case .failure(let error) = result {
                    self.onError(error)
                    return
                }
                if let parsed = try? result.get() {
                    
                    let text = InputMessageText(
                        clearDraft: false,
                        disableWebPagePreview: true,
                        text: parsed)
                    
                    self.sendFormattedTextMessage(text)
                }
            }
        )
    }
    
    func openChat() {
        self.forceUpdate()
        self.chatIsOpen = true
        try? api.openChat(chatId: chatId, completion: { [weak self] result in
                self?.checkResult(result)
        })
    }
    
    func closeChat() {
        self.forceUpdate()
        self.chatIsOpen = false
        self.messages.cutTo(size: 60)
        self.finishedLoading = true
        try? api.closeChat(chatId: chatId, completion: { [weak self] result in
                self?.checkResult(result)
        })
    }
    
    func readMessage(_ messageId: Int64) {
        let chatInfo = ServiceLayer.instance.chatListService.chats[chatId]!
        
        if chatInfo.unreadCount == 0 { return }
        if messageId <= chatInfo.lastReadInboxMessageId { return }
        
        try? api.viewMessages(chatId: chatId,
                              forceRead: true,
                              messageIds: [messageId],
                              messageThreadId: 0,
                              completion:
        { [weak self] result in
            guard
                let self = self,
                let _ = try? result.get() else { return }
            
            self.checkResult(result)
        })
    }
    
    // MARK: Private methods
    
    private func sendFormattedTextMessage(_ text: InputMessageText) {
        try? api.sendMessage(
            chatId: chatId,
            inputMessageContent: InputMessageContent.inputMessageText(text),
            messageThreadId: 0,
            options: nil,
            replyMarkup: nil,
            replyToMessageId: 0,
            completion: { [weak self] result in
                guard
                    let self = self,
                    let _ = try? result.get() else { return }
                
                self.checkResult(result)
                if (try? result.get()) != nil {
                    //0;
                    // self.addMessages([message])
                }
            }
        )
    }
    
    private func checkResult<T>(_ result: Result<T, Swift.Error>) {
        if case .failure(let error) = result {
            self.onError(error)
            return
        }
    }

}

protocol ConversationServiceDelegate: class {
    func messagesUpdated()
    func onError(_ error: Swift.Error)
}
