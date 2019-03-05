//
//  Conversation.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/28/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation
import Firebase

class Conversation: NSObject, Codable {
    
    // fromUserRef and toUserRef are required to create a conversation
    var fromUserRef: DocumentReference
    var toUserRef: DocumentReference
    
    // fromUserID and toUserID are required to check if a user is initiating a new conversation
    var fromUserID: String
    var toUserID: String
    
    // Reference to the conversation document in Firestore
    var ref: DocumentReference?

    
    init(fromUser: User, toUser: User) {
        self.fromUserRef = fromUser.ref!
        self.toUserRef = toUser.ref!
        self.fromUserID = fromUser.phoneID
        self.toUserID = toUser.phoneID
    }
    
    
    
    // Those who implement UserLocationListener should call this and pass self
    // in order to receive updates when a new message is sent.
    func addConversationListener(listener: ConversationListener) {
        // Listen only to new messages that are sent
        ref?.collection("messages")
            .whereField("timestampDate", isGreaterThan: Timestamp(date: Date(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970 - 1))))
            .addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let message = TextMessage(values: diff.document.data())
                    listener.conversationChanged(textMessage: message)
                }
                /* if (diff.type == .modified) {
                    print("Modified city: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removed city: \(diff.document.data())")
                } */
            }
        }
    }
}

// Conform to this protocol if you want to receive updates when the user's location changes
protocol ConversationListener {
    func conversationChanged(textMessage: TextMessage)
}
