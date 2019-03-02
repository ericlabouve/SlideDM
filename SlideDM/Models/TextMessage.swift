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
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.text = text
        self.id = sender.id
        self.displayName = sender.displayName
        self.messageId = messageId
        timestampDate = Timestamp(date: date)
    }

    // CodableFirebase was not working so I had to encode/decode by hand...
    
    // TODO next time: Decode the textmessage from firebase. Here is a sample decode function:
    
//    init(key: String, snapshot: DataSnapshot) {
//        name = key
//
//        let snaptemp = snapshot.value as! [String : AnyObject]
//        let snapvalues = snaptemp[key] as! [String : AnyObject]
//
//        name = snapvalues["name"] as? String ?? "N/A"
//        city = snapvalues["city"] as? String ?? "N/A"
//        state = snapvalues["state"] as? String ?? "N/A"
//        zip = snapvalues["zip"] as? String ?? "N/A"
//        contact_email = snapvalues["contact_email"] as? String ?? "N/A"
//        latitude = snapvalues["latitude"] as? Double ?? 0.0
//        longitude = snapvalues["longitude"] as? Double ?? 0.0
//
//        super.init()
//    }
    //
    // And here is the old way to get all the docs from firebase
    // https://github.com/ericlabouve/csc436lab7/blob/master/csc436lab7/ViewControllers/ViewController.swift
    //
    // Would be a good idea to look into observing a collection with snapshots
    
    
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

