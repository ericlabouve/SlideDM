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

class User: Codable {
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
    var contacts: [Contact]
    // Reference to the user in Firestore
    var ref: DocumentReference?

//    // A list of conversations that the user is a part of
    var conversations = [Conversation]()
//    var conversations = [ConversationDocRef]()
////    var conversations = [DocumentReference]()
//
//    // Helper class to hold a reference to a conversation document
//    struct ConversationDocRef: Codable {
//        var ref: DocumentReference
//        // Unique ID of the toUser in this conversation
//        // Optimization to include the toUser so we can check which users this user already has conversations with so
//        // that when we send a message to a NEW user, we don't have to look up all of this user's previous conversation buddies.
//        var toUserID: String
//
//    }
    
    init(first: String, last: String, phoneID: String, contacts: [Contact]) {
        self.first = first
        self.last = last
        self.phoneID = phoneID
        self.contacts = contacts
//        ref = nil
        self.greetingTag = getRandomGreetingTag()
    }
    
    func getRandomGreetingTag() -> String {
        var message = ""
        message += ["Hi ", "Hello ", "Greetings ", "Salutations ", "Holla "].randomElement()!
        message += ["friends! ", "world! ", "everyone! ", "amigos! "].randomElement()!
        message += ["Who wants to ", "Anyone down to ", "Lets all "].randomElement()!
        message += ["hang out?", "grab some pizza?", "go to a concert?", "get some food?", "meet up?"].randomElement()!
        return message
    }
    
    
    // Return the conversation associated between this user and the user identified by userID
    func getConversationWith(userID id: String) -> Conversation? {
        for conversation in conversations {
            if id == conversation.toUserID {
                return conversation
            }
        }
        return nil
    }
    
    
}
