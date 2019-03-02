//
//  TextMessage.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/26/19.
//

import Foundation
import CoreLocation
import MessageKit
import Firebase

// MKMessage can be extended to support many different kinds of messages.
// Please look at the original documentation for MessageKit more details :)
class TextMessage: MessageType, Codable {
    
    // Unique ID for the message
    var messageId: String
    
    // Unique ID for the sending user
    var sender: Sender
    
    // Date at which the message was sent
    var timestampDate: Timestamp
    // Dates are not Codable, but are required by MessageType.
    var sentDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(timestampDate.seconds))
    }
    
    // Enum representing the kind of the message (text, image, etc)
    var text: String
    // MessageKind is not codable
    var kind: MessageKind {
        return .text(text)
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.text = text
        self.sender = sender
        self.messageId = messageId
        timestampDate = Timestamp(date: date)
    }
}
