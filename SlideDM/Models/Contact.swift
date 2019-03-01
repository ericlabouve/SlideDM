//
//  Contact.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/7/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation

// A Contact is an individual that the user "knows" through their Contacts app.
class Contact: Codable {
    // First name
    var first: String
    // Last name
    var last: String
    // These are the contact's hashed phone numbers
    var phoneIDs: [String]
    
    init(first: String, last: String, phoneIDs: [String]) {
        self.first = first
        self.last = last
        self.phoneIDs = phoneIDs
    }
    
//    func toDict() -> [String: Any] {
//        return [
//            "first" : first,
//            "last" : last,
//            "phoneIDs" : phoneIDs
//        ]
//    }
}
