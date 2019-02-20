//
//  User.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation

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

    // var uniqueID: String
    // var location: ~GeoFireLocation~
    // var profileImage: UIImage
    // var chatThreads: [ChatThread]
    
    init(first: String, last: String, phoneID: String) {
        self.first = first
        self.last = last
        self.phoneID = phoneID
        greetingTag = getRandomGreetingTag()
    }
    
    // Convert dictionary obtained from document back into a user
    init(dictionary: [String: Any]) {
        self.first = dictionary["first"] as? String ?? ""
        self.last = dictionary["last"] as? String ?? ""
        self.phoneID = dictionary["phoneID"] as? String ?? ""
        greetingTag = getRandomGreetingTag()
        // Also decompose this one...
//        self.contacts
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
        return [
            "first" : first,
            "last" : last,
            "phoneID" : phoneID,
            "contacts" : contactList
        ]
    }
}
