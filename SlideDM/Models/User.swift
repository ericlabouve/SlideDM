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
import CodableFirebase

class User: Codable, Equatable {
    // User's first name
    var first: String
    // User's last name
    var last: String
    // User's email address
    var email: String
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

    // A list of conversations that the user is a part of.
    // Stored in a collection called conversations
    var conversations = [Conversation]()

    
    init(first: String, last: String, email: String, phoneID: String, contacts: [Contact]) {
        self.first = first
        self.last = last
        self.email = email
        self.phoneID = phoneID
        self.contacts = contacts
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
            if id == conversation.toUserID || id == conversation.fromUserID {
                return conversation
            }
        }
        return nil
    }
    
    // Include everything except the conversations list because conversations is stored in a separate collection
    // to make conversations observable
    enum CodingKeys: String, CodingKey {
        case first
        case last
        case email
        case phoneID
        case greetingTag
        case profileImageName
        case distanceMetric
        case contacts
        case ref
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.phoneID == rhs.phoneID
    }
    
    
    // Listens for any new conversations that the user becomes a part of.
    func addUserConversationsListener(listener: UserConversationsListener) {
        // Listen to all the user's conversations and any changes
        ref?.collection("conversations").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { print("Error fetching conversation snapshot: \(error!)"); return }
            // First time this is ran it will return all documents in the collection, which will be used to initialize all
            // Conversation.ConversationListeners
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let conversation = try! FirestoreDecoder().decode(Conversation.self, from: diff.document.data())
                    listener.UserConversationsChanged(user: self, conversation: conversation)
                }
            }
        }
    }
}

// Conform to this protocol to receive updates when a conversation is added to a user's conversations collection
// Idealy have one account listening to one user
protocol UserConversationsListener {
    func UserConversationsChanged(user: User, conversation: Conversation)
}
