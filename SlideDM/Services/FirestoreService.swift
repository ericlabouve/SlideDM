//
//  FirestoreService.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/18/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation
import Geofirestore
import Firebase
import CoreLocation

// Singleton that is used to store information and instances shared across the app.
class FirestoreService {
    static let shared = FirestoreService()
    
    // users
    //  - first: String
    //  - last: String
    //  - phoneID: String
    //  - contacts: [{
    //                  first: String
    //                  last: String
    //                  phoneIDs: [String]
    //              }]
    //  - conversations: [DocumentReference]
    var userColRef: CollectionReference!

    // Geofirestore
    // TODO: This will need to be refactored to include a user's location inside a user's document
    var geoFirestoreRef: CollectionReference
    var geoFirestore: GeoFirestore
    
    // conversations
    //  - fromUser: String
    //  - toUser: String
    //  - messages: collection
    //     - text: String
    //     - user: String
    //     - time: Date
    var conversationsRef: CollectionReference
    
    private init() {
        // Load Firestore and Geofirestore
        geoFirestoreRef = Firestore.firestore().collection("geoFirestore")
        geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        userColRef = Firestore.firestore().collection("users")
        
        conversationsRef = Firestore.firestore().collection("conversations")
    }

}
