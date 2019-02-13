//
//  User.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation

class User {
    var first: String
    var last: String
    // User's encrypted phone number
    var phoneID: String
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
