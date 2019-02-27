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
    
    var userColRef: CollectionReference!
    
    // Geofirestore - This will need to be refactored to include a user's location inside a user's document
    var geoFirestoreRef: CollectionReference
    var geoFirestore: GeoFirestore
    
    private init() {
        // Load Firestore and Geofirestore
        geoFirestoreRef = Firestore.firestore().collection("geoFirestore")
        geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        userColRef = Firestore.firestore().collection("users")
    }

}
