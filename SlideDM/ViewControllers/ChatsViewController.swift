//
//  ChatsViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// TODO:
// [] Is there a better way to perform queries? Right now pulling nearby users makes two database calls per user. I should be able to pull users directly by saving the location in the user.
// Potential fix for 2-level inversion to get user locations:
// https://github.com/firebase/geofire-objc/issues/101
// [] Wifi connectivity popup when user's data can't be loaded

import UIKit
import CoreLocation
import Firebase
import CodableFirebase

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserLocationListener {
    
    // User Interface
    @IBOutlet weak var tableView: UITableView!
    
    // Meta Data
    // Maintain this list for the TableView
    var nearbyUsers = [User]()
    var selectedUser: User?
    var user: User!
    
    
    // View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.shared.addLocationListener(listener: self)
        loadUser()
    }
    
    // Fetch the user from Firestore
    func loadUser() {
        guard let userDocID = UserDefaults.standard.string(forKey: "userDocID") else {
            print("Cannot find user ID in UserDefaults.standard")
            return
        }
        // Get user from the database
        FirestoreService.shared.userColRef.document(userDocID).getDocument { (document, error) in
            if let document = document {
                self.user = try! FirestoreDecoder().decode(User.self, from: document.data()!)
            } else {
                // Probably shouldn't crash app. Should display a notification to the user to connect to wifi
                fatalError("Could not fetch user")
            }
        }
        
    }
    
    
    // MARK: - UserLocationListener methods
    
    // IDEA: Consider using a snapshot listener to listen for updates in an entire collection?
    
    // Called ~once~ upon startup because we called addLocationListener in viewDidLoad
    // Using the user's location, query the database for all nearby users who are part of the user's social
    // network and add them to the tableView
    func userLocationChanged(userLocation: CLLocation?) {
        
        guard let center = userLocation else {
            print("User's location not found")
            return
        }
        // 5 miles = 8.04672 kilometers
        let circleQuery = FirestoreService.shared.geoFirestore.query(withCenter: center, radius: 300)
        // Refactor this into FirestoreService later
        //            circleQuery.observe(.documentEntered, with: { (key: String?, location: CLLocation?) in
        //                // key contains our user id and location contains that user's location
        //
        //                // Load each user corresponding to each document key
        //                let docRef = FirestoreService.shared.userColRef.document(key!)
        ////                let docRef = Firestore.firestore().collection("users").document(key!)
        //                docRef.getDocument { (document, error) in
        //                    if let document = document, document.exists {
        // Uncomment
        //                        let nearbyUser = User(snapshot: document)
        //                        if self.user?.phoneID != nearbyUser.phoneID {
        //                            self.nearbyUsers.append(nearbyUser)
        //                        }
        //
        //
        //                    } else {
        //                        print("Document does not exist")
        //                    }
        //                    // Reload the tableView in the main thread
        //                    DispatchQueue.main.async {
        //                        self.tableView.reloadData()
        //                    }
        //                }
        //            })
        
        
        // Update table
//        if let center = userLocation {
//            // 5 miles = 8.04672 kilometers
//            let circleQuery = FirestoreService.shared.geoFirestore.query(withCenter: center, radius: 300)
//            // Refactor this into FirestoreService later
//            circleQuery.observe(.documentEntered, with: { (key: String?, location: CLLocation?) in
//                // key contains our user id and location contains that user's location
//
//                // Load each user corresponding to each document key
//                let docRef = FirestoreService.shared.userColRef.document(key!)
////                let docRef = Firestore.firestore().collection("users").document(key!)
//                docRef.getDocument { (document, error) in
//                    if let document = document, document.exists {
// Uncomment
//                        let nearbyUser = User(snapshot: document)
//                        if self.user?.phoneID != nearbyUser.phoneID {
//                            self.nearbyUsers.append(nearbyUser)
//                        }
//
//
//                    } else {
//                        print("Document does not exist")
//                    }
//                    // Reload the tableView in the main thread
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//            })
//        } else {
//            print("User's location was null in userLocationChanged()")
//        }
    }

  
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let segueID = segue.identifier!
        if segueID == "ChatsToChatroom" {
            let destinationVC = segue.destination as! ChatRoomViewController
            destinationVC.toUser = selectedUser
            destinationVC.fromUser = user
        }
        else if segueID == "ChatsToProfile" {
            let destinationVC = segue.destination as! ProfileViewController
            destinationVC.user = user
        }
    }

    
    //MARK: - Table View Methods
    
    // Section is jargon for column
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyUsers.count
    }
    
    // Set up the contents of a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell", for: indexPath) as? ChatsTableViewCell
        let thisUser = nearbyUsers[indexPath.row]
        cell?.nameLabel.text = thisUser.first + " " + thisUser.last
        cell?.distanceLabel.text = thisUser.distanceMetric
        cell?.greetingTagTextView.text = thisUser.greetingTag
        cell?.iconImageView.image = UIImage(named: thisUser.profileImageName)
        return cell!
    }
    
    // Set the height of each of the rows
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // Selecting a table cell will transition the user into the chat room
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = nearbyUsers[indexPath.row]
//        performSegue(withIdentifier: "ChatsToChatroom", sender: self)
        performSegue(withIdentifier: "ChatsToChatroom", sender: self)
    }
}
