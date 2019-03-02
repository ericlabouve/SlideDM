//
//  Conversation.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/28/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//
// TODO:
// [] Change messages to a collection String ID

import Foundation
import Firebase

class Conversation: Codable {
    
    // fromUserRef and toUserRef are required to create a conversation
    var fromUserRef: DocumentReference
    var toUserRef: DocumentReference
    
    // fromUserID and toUserID are required to check if a user is initiating a new conversation
    var fromUserID: String
    var toUserID: String
    
    var ref: DocumentReference?
    
    // To support pagination, this will probabily need to be changed to a collection of message documents
//    var messagesColRef: CollectionReference?
    var messages = [TextMessage]()
    
    init(fromUser: User, toUser: User) {
        self.fromUserRef = fromUser.ref!
        self.toUserRef = toUser.ref!
        self.fromUserID = fromUser.phoneID
        self.toUserID = toUser.phoneID
    }
    
//    init(snapshot: DocumentSnapshot) {
//        let values = snapshot.data()!
//
//        self.fromUserRef = values["fromUserRef"] as! DocumentReference
//        self.toUserRef = values["toUserRef"] as! DocumentReference
////        self.messagesColRef = values["messagesColRef"] as? CollectionReference
//        self.messages = values["messages"] as! [TextMessage]
//    }
    
//    func toDict() -> [String : Any] {
//        var messageList: [[String : Any]] = []
//        for message in messages {
//            messageList.append(message.toDict())
//        }
//        return [
//            "fromUserRef" : fromUserRef.documentID,
//            "toUserRef" : toUserRef.documentID,
////            "messagesColRef" : (messagesColRef?.collectionID)!
//            "messages" : messageList
//        ]
//    }
}
