//
//  FirestoreService.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/18/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//
// TODO:
// [] getUser shouldn't have fatal errors. Should have a popup warning for internet connection errors.

import Foundation
import Geofirestore
import Firebase
import CoreLocation
import CodableFirebase

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
    var conversationsColRef: CollectionReference
    
    private init() {
        // Load Firestore and Geofirestore
        geoFirestoreRef = Firestore.firestore().collection("geoFirestore")
        geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        userColRef = Firestore.firestore().collection("users")
        
        conversationsColRef = Firestore.firestore().collection("conversations")
    }
    
    func getUser(completion: @escaping (User) -> Void) {
        guard let userDocID = UserDefaults.standard.string(forKey: "userDocID") else {
            fatalError("Cannot find user ID in UserDefaults.standard")
        }
        // Get user from the database
        let userDocRef = FirestoreService.shared.userColRef.document(userDocID)
        userDocRef.getDocument { (document, error) in
            if let document = document {
                var user = try! FirestoreDecoder().decode(User.self, from: document.data()!)
                user.ref = userDocRef
                completion(user)
            } else {
                // Probably shouldn't crash app. Should display a notification to the user to connect to wifi
                fatalError("Could not fetch user")
            }
        }
    }
}

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}
