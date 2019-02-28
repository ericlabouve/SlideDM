//
//  User.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

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
    
    let ref: DocumentReference?
    
    // A list of conversations that the user is a part of
    var conversations = [DocumentReference]()

    // var uniqueID: String
    // var location: ~GeoFireLocation~
    // var profileImage: UIImage
    
    init(first: String, last: String, phoneID: String) {
        self.first = first
        self.last = last
        self.phoneID = phoneID
        ref = nil
        greetingTag = getRandomGreetingTag()
    }
    

    // Convert dictionary obtained from document back into a user
//    init(dictionary: [String: Any]) {
    init(snapshot: DocumentSnapshot) {
        let values = snapshot.data()!
        
        self.first = values["first"] as! String
        self.last = values["last"] as! String
        self.phoneID = values["phoneID"] as! String
        self.contacts = (values["contacts"] as! [Contact])
        self.ref = snapshot.reference
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
    
    func toDict() -> [String: Any] {
        var contactList: [[String: Any]] = []
        if let contacts = contacts {
            for contact in contacts {
                contactList.append(contact.toDict())
            }
        }
//        var conversationList: [String]
        return [
            "first" : first,
            "last" : last,
            "phoneID" : phoneID,
            "contacts" : contactList
        ]
    }
}
