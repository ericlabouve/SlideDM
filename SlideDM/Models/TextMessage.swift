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
import CodableFirebase

// MKMessage can be extended to support many different kinds of messages.
// Please look at the original documentation for MessageKit more details :)
class TextMessage: MessageType, Codable {
    
    // Unique ID for the message
    var messageId: String
    
    // fromUser's unique phoneID
    var id: String
    var displayName: String
    var sender: Sender {
        return Sender(id: id, displayName: displayName)
    }
    
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
    
    // Whether or not the user's avatar should show next to their message
    // Should show once per group of messages
    var showAvatar: Bool = false
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.text = text
        self.id = sender.id
        self.displayName = sender.displayName
        self.messageId = messageId
        timestampDate = Timestamp(date: date)
    }

    // CodableFirebase was not working so I had to encode/decode by hand...
    convenience init(snapshot: QueryDocumentSnapshot) {
        self.init(values: snapshot.data())
    }
    
    init(values: [String : Any]) {
        self.messageId = values["messageId"] as! String
        self.id = values["id"] as! String
        self.displayName = values["displayName"] as! String
        self.timestampDate = Timestamp(date: values["timestampDate"] as! Date)
        self.text = values["text"] as! String
    }
    
    func toDict() -> [String : Any] {
        return [
            "messageId" : messageId,
            "id" : id,
            "displayName" : displayName,
            "timestampDate" : timestampDate,
            "text" : text
        ]
    }
}

