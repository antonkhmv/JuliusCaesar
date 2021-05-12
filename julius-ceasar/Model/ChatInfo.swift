import Foundation
import TdlibKit

struct  ChatInfo {
    
    let id: Int64
    var positions: [ChatPosition]
    var title: String
    var isMarkedAsUnread: Bool
    var unreadCount: Int
    var unreadMentionCount: Int
    var lastReadInboxMessageId: Int64
    var lastReadOutboxMessageId: Int64
    var lastMessage: TextMessage?
    var isPersonal: Bool
    var chatPhoto: Int?
    
    init(
        id: Int64,
        positions: [ChatPosition],
        title: String,
        isMarkedAsUnread: Bool = false,
        unreadCount: Int = 0,
        unreadMentionCount: Int = 0,
        lastReadInboxMessageId: Int64 = 0,
        lastReadOutboxMessageId: Int64 = 0,
        lastMessage: TextMessage? = nil,
        isPersonal: Bool,
        chatPhoto: Int?) {
        
        self.isPersonal = isPersonal
        self.id = id
        self.positions = positions
        self.title = title
        self.isMarkedAsUnread = isMarkedAsUnread
        self.unreadCount = unreadCount
        self.unreadMentionCount = unreadMentionCount
        self.lastReadInboxMessageId = lastReadInboxMessageId
        self.lastReadOutboxMessageId = lastReadOutboxMessageId
        self.chatPhoto = chatPhoto
    }
}


extension ChatInfo {
    
    init(_ chat: Chat) {
        chatPhoto = chat.photo?.big.id
        id = chat.id
        positions = chat.positions
        title = chat.title
        isMarkedAsUnread = chat.isMarkedAsUnread
        unreadCount = chat.unreadCount
        unreadMentionCount = chat.unreadMentionCount
        lastReadInboxMessageId = chat.lastReadInboxMessageId
        lastReadOutboxMessageId = chat.lastReadOutboxMessageId
        switch (chat.type) {
        case .chatTypePrivate(_):
            isPersonal = true
        default:
            isPersonal = false
        }
        if let message = chat.lastMessage {
            lastMessage = TextMessage(message)
        }
    }
}
