//
//  TextMessage.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/26/19.
//

import Foundation
import CoreLocation
import MessageKit

// MKMessage can be extended to support many different kinds of messages.
// Please look at the original documentation for MessageKit more details :)
internal struct TextMessage: MessageType {
    // Unique ID for the message
    var messageId: String
    // Unique ID for the sending user
    var sender: Sender
    // Date at which the message was sent
    var sentDate: Date
    // Enum representing the kind of the message (text, image, etc)
    var kind: MessageKind
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.kind = .text(text)
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    
    func toDict() -> [String: Any] {
        var textContent = ""
        switch kind {
        case let .text(textContent_):
            textContent = textContent_
        default:
            textContent = "Error"
        }
        
        return [
            "messageId" : messageId,
            "sender" : sender.toDict(),
            //            "sentDate" : sentDate,        // Question for lab: how do i store a date in firestore?
            "text" : textContent
        ]
    }
}

extension Sender {
    func toDict() -> [String: Any] {
        return [
            "displayName" : self.displayName,
            "id" : self.id
        ]
    }
}
