import Foundation
import TdlibKit
import SwiftUI

struct TextMessage : Hashable, Equatable {
    let uuid = UUID()
    let id: Int64
    let chatId: Int64
    let date: Foundation.Date
    let senderUserId: Int
    let senderChatId: Int64
    let isChannelPost: Bool
    let isOutgoing: Bool
    private(set) var text: String?
    var isDateShown: Bool
    var user: Int?
    private(set) var links: [String]?
    var photo: Photo?
    var doc: Document?
}

extension TextMessage {
    
    init(_ message: Message) {
        id = message.id
        chatId = message.chatId
        date = Foundation.Date(timeIntervalSince1970: TimeInterval(message.date))
        switch message.sender {
        case .messageSenderUser(let user):
            senderUserId = user.userId
            senderChatId = 0
        case .messageSenderChat(let chat):
            senderUserId = 0
            senderChatId = chat.chatId
        }
        isChannelPost = message.isChannelPost
        isOutgoing = message.isOutgoing
        isDateShown = false
        text = self.makeText(message.content)
    }
    
    mutating func updateContent(_ content: MessageContent) {
        text = self.makeText(content)
    }
    
    private mutating func makeText(_ content: MessageContent) -> String? {
        switch content {
        case .messageText(let text):
            self.getLinks(from: text.text)
            return text.text.text
            
        case .messageAnimation(let ani):
            self.getLinks(from: ani.caption)
            return ani.caption.text
            
        case .messageAudio(let audio):
            self.getLinks(from: audio.caption)
            return audio.caption.text + "(toString(\(audio.audio.duration)))"
            
        case .messageDocument(let doc):
            self.getLinks(from: doc.caption)
            self.doc = doc.document
            return doc.caption.text
            
        case .messagePhoto(let photo):
            self.photo = photo.photo 
            self.getLinks(from: photo.caption)
            return photo.caption.text
            
        case .messageSticker(let sticker):
            return sticker.sticker.emoji
            
        case .messageVideo(let video):
            self.getLinks(from: video.caption)
            return "Video \(timeToString(video.video.duration))\n"
                + video.caption.text
            
        case .messagePoll(let poll):
            var pollStr = ""
            pollStr += poll.poll.question + "\n"
            
            if !poll.poll.options.allSatisfy({ option in !option.isChosen }) {
                for option in poll.poll.options {
                    pollStr += option.text +
                        " \(option.votePercentage)% - \(option.voterCount)\n"
                }
            }
            else {
                for option in poll.poll.options {
                    pollStr += option.text
                }
            }
            
            return pollStr
            
        case .messageCall(let call):
            var reason: String
            
            switch(call.discardReason) {
            case .callDiscardReasonDeclined:
                reason = "declined"
            case .callDiscardReasonMissed:
                reason = "missed"
            case .callDiscardReasonDisconnected:
                reason = "disconnected"
            default:
                reason = ""
            }
            
            return (isOutgoing ? "Outgoing" : "Incoming")
                + " call (\(timeToString(call.duration))) " + reason
        
        case .messageVoiceNote(let message):
            self.getLinks(from: message.caption)
            return "Voice message (\(timeToString(message.voiceNote.duration)))\n"
                    + message.caption.text
            
        case .messageVideoNote(let message):
            return "Video note (\(timeToString(message.videoNote.duration)))"
            
        case .messageDice(let dice):
            return "\(dice.emoji) value = \(dice.value)"
            
        default:
            return nil
        }
    }

    private mutating func getLinks(from: FormattedText) {
        
        for e in from.entities {
            if case .textEntityTypeUrl = e.type {
                
                var substr = from.text.substring(with: NSRange(location: e.offset, length: e.length))!
                
                if !substr.starts(with: "https://") && !substr.starts(with: "http://") {
                    substr = "https://" + substr
                }
                
                if self.links == nil {
                    self.links = [substr]
                }
                else {
                    self.links!.append(substr)
                }
            }
        }
        
    }
}

extension String {
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
}
