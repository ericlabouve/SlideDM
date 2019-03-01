//
//  User.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// TODO: profileImage: UIImage

import Foundation
import Firebase

class User {
    // User's first name
    var first: String
    // User's last name
    var last: String
    // User's encrypted phone number
    var phoneID: String
    // User's greeting tag message
    var greetingTag: String = ""
    // Profile image icon (initially set to a default icon)
    var profileImageName: String = "defaultIcon"
    // Distance relative to active user
    // Nearby, Further away, Not close
    var distanceMetric: String = "Nearby"
    // List of contacts that represent people the user knows
    var contacts: [Contact]?
    // Reference to the user in Firestore
    let ref: DocumentReference?
    // A list of conversations that the user is a part of
    var conversations = [ConversationDocRef]()
//    var conversations = [DocumentReference]()

    // Helper class to hold a reference to a conversation document
    struct ConversationDocRef {
        var ref: DocumentReference
        // Unique ID of the toUser in this conversation
        // Optimization to include the toUser so we can check which users this user already has conversations with so
        // that when we send a message to a NEW user, we don't have to look up all of this user's previous conversation buddies.
        var toUser: String

        func toDict() -> [String: Any] {
            return [
                "ref" : ref.documentID,
                "toUser" : toUser,
            ]
        }
    }
    
    init(first: String, last: String, phoneID: String) {
        self.first = first
        self.last = last
        self.phoneID = phoneID
        ref = nil
        greetingTag = getRandomGreetingTag()
    }

    // Convert dictionary obtained from document back into a user
    init(snapshot: DocumentSnapshot) {
        let values = snapshot.data()!
        
        self.first = values["first"] as! String
        self.last = values["last"] as! String
        self.phoneID = values["phoneID"] as! String
        self.contacts = (values["contacts"] as! [Contact])              // Crashes because this is not correct... Is there a better way? With Codable? Json?
        
//        var contacts_temp = (values["contacts"] as! [Contact])
//        for c in contacts_temp {
//            self.contacts?.append(Contact(first: c.first, last: c.last, phoneIDs: <#T##[String]#>))
//        }
        
        self.ref = snapshot.reference
        self.conversations = (values["conversations"] as! [ConversationDocRef])
//        self.conversations = values["conversations"] as! [DocumentReference]
        self.greetingTag = getRandomGreetingTag()
    }
    
    
    
    // Get the ConversationDocRef given a userId
    func getConversation(withId id: String) -> ConversationDocRef? {
        for conversation in conversations {
            if id == conversation.toUser {
                return conversation
            }
        }
        return nil
    }
    
    func getRandomGreetingTag() -> String {
        var message = ""
        message += ["Hi ", "Hello ", "Greetings ", "Salutations ", "Holla "].randomElement()!
        message += ["friends! ", "world! ", "everyone! ", "amigos! "].randomElement()!
        message += ["Who wants to ", "Anyone down to ", "Lets all "].randomElement()!
        message += ["hang out?", "grab some pizza?", "go to a concert?", "get some food?", "meet up?"].randomElement()!
        return message
    }
    
    func toDict() -> [String: Any] {
        var contactList: [[String: Any]] = []
        if let contacts = contacts {
            for contact in contacts {
                contactList.append(contact.toDict())
            }
        }
        var conversationList: [[String: Any]] = []
//        var conversationList: [String] = []
        for conversation in conversations {
            conversationList.append(conversation.toDict())
//            conversationList.append(conversation.documentID)
        }
        return [
            "first" : first,
            "last" : last,
            "phoneID" : phoneID,
            "contacts" : contactList,
            "conversations" : conversationList
        ]
    }
}
