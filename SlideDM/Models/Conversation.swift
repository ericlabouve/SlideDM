//
//  Conversation.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/28/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation
import Firebase

class Conversation {
    // fromUserRef and toUserRef are required to create a conversation
    var fromUserRef: DocumentReference
    var toUserRef: DocumentReference
    // To support pagination, this will probabily need to be changed to a collection of message documents
//    var messagesColRef: CollectionReference?
    var messages = [TextMessage]()
    
    init(fromUserRef: DocumentReference, toUserRef: DocumentReference) {
        self.fromUserRef = fromUserRef
        self.toUserRef = toUserRef
    }
    
    init(snapshot: DocumentSnapshot) {
        let values = snapshot.data()!
        
        self.fromUserRef = values["fromUserRef"] as! DocumentReference
        self.toUserRef = values["toUserRef"] as! DocumentReference
//        self.messagesColRef = values["messagesColRef"] as? CollectionReference
        self.messages = values["messages"] as! [TextMessage]
    }
    
    func toDict() -> [String : Any] {
        var messageList: [[String : Any]] = []
        for message in messages {
            messageList.append(message.toDict())
        }
        return [
            "fromUserRef" : fromUserRef.documentID,
            "toUserRef" : toUserRef.documentID,
//            "messagesColRef" : (messagesColRef?.collectionID)!
            "messages" : messageList
        ]
    }
}
