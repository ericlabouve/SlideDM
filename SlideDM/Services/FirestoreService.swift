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
    
    // Reference to a collection of users
    var userColRef: CollectionReference!

    // Geofirestore
    // TODO: This will need to be refactored to include a user's location inside a user's document
    var geoFirestoreRef: CollectionReference
    var geoFirestore: GeoFirestore
    
    // Reference to a collection of shared conversations
    var conversationsColRef: CollectionReference
    
    private init() {
        // Load Firestore and Geofirestore
        geoFirestoreRef = Firestore.firestore().collection("geoFirestore")
        geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        userColRef = Firestore.firestore().collection("users")
        
        conversationsColRef = Firestore.firestore().collection("conversations")
    }
    
    func getUser(completion: @escaping (SDMUser) -> Void) {
        guard let userDocID = UserDefaults.standard.string(forKey: "userDocID") else {
            fatalError("Cannot find user ID in UserDefaults.standard")
        }
        // Get user from the database
        let userDocRef = FirestoreService.shared.userColRef.document(userDocID)
        userDocRef.getDocument { (document, error) in
            if let document = document {
                var user = try! FirestoreDecoder().decode(SDMUser.self, from: document.data()!)
                user.ref = userDocRef
                FirestoreService.shared.loadUserConversations(user)
                completion(user)
            } else {
                // Probably shouldn't crash app. Should display a notification to the user to connect to wifi
                fatalError("Could not fetch user")
            }
        }
    }
    
    // Fetches and fills out all of this user's conversations
    func loadUserConversations(_ user: SDMUser) {
        guard let ref = user.ref else { return }
        // Get every document in the user's conversations collection
        ref.collection("conversations").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting Conversation document from user \(String(describing: user.ref)): \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let conversation = try! FirestoreDecoder().decode(Conversation.self, from: document.data())
                    user.conversations.append(conversation)
                }
            }
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, withPath path: String) {
        let storageRef = Storage.storage().reference(withPath: path)
        let data = (image.pngData() as Data?)!
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/png"
        storageRef.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if (error != nil) {
                print("Error while uploading image: \(error?.localizedDescription)")
            } else {
                print(metadata)
            }
            
        }
    }
}

// CodableFirebase extensions to make these types Codable
extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}
