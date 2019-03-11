//
//  ChatsViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// TODO:
// [X] Snapshot listeners on all conversations
// [X] Listen for conversations that have not started yet
//      -- Maybe use a snapshot listener on a user's conversation list?
// [] Is there a better way to perform queries? Right now pulling nearby users makes two database calls per user. I should be able to pull users directly by saving the location in the user.
// Potential fix for 2-level inversion to get user locations:
// https://github.com/firebase/geofire-objc/issues/101
// [] BUG: Separate conversations are created between two users
// [] Background process to update user's location
//      [x] Pull up to reload everything
// [] BUG: geoFirestore.query returns documents that don't exist...
// [] Wifi connectivity popup when user's data can't be loaded

import UIKit
import CoreLocation
import Firebase
import CodableFirebase

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserLocationListener, UserConversationsListener, ConversationListener {

    // User Interface
    @IBOutlet weak var tableView: UITableView!
    // Scroll wheel to refresh user's location and the tableView
    let refreshControl = UIRefreshControl()
    
    // Meta Data
    // Maintain this list for the TableView
    var nearbyUsers = [User]()
    var selectedUser: User?
    var user: User!
    
    // Keep track of a list of conversations we are listening to
    // list of conversations ids ??
    
    // View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.shared.addLocationListener(listener: self)
        refreshControl.addTarget(self, action: #selector(refreshLocation), for: .valueChanged)
        tableView.addSubview(refreshControl)
        FirestoreService.shared.getUser { user in
            self.user = user
            self.user.addUserConversationsListener(listener: self)
        }
    }
    
    
    
    
    
    // MARK: - UserConversationsListener and ConversationListener methods
    
    func conversationChanged(conversation: Conversation, textMessage: TextMessage) {
        // Only react to messages sent to the user and not from the user
        let fromId = textMessage.id
        if fromId != user.phoneID {
            // Get the table cell that corresponds to this conversation
            for (idx, nearbyUser) in nearbyUsers.enumerated() {
                if fromId == nearbyUser.phoneID {
                    // Put the contact with the new message at the top of the list
                    let element = nearbyUsers.remove(at: idx)
                    nearbyUsers.insert(element, at: 0)
                    // Color the conversation
                    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChatsTableViewCell
                    cell?.read = false
                    // Set the greeting tag as a message preview
                    nearbyUser.greetingTag = textMessage.text
                    tableView.reloadData()
                    break
                }
            }
        }
    }

    // Our user has been added (or has been added to) a new conversation.
    // Listen to this conversation for future messages
    func UserConversationsChanged(user: User, conversation: Conversation) {
        conversation.addConversationListener(listener: self)
        user.conversations.append(conversation)
    }
    
    
    
    
    
    
    // MARK: - UserLocationListener and Location methods
    
    @objc func refreshLocation() {
        self.nearbyUsers.removeAll()
        LocationService.shared.updateLocation()
        self.refreshControl.endRefreshing()
    }
    
    
    
    
    // Called ~once~ upon startup because we called addLocationListener in viewDidLoad
    // Using the user's location, query the database for all nearby users who are part of the user's social
    // network and add them to the tableView
    func userLocationChanged(userLocation: CLLocation?) {
        guard let center = userLocation else { print("User's location not found"); return }
        // 5 miles = 8.04672 kilometers
        let circleQuery = FirestoreService.shared.geoFirestore.query(withCenter: center, radius: 300)
        
        // Fires one at a time as users are discovered
        // If a user updates locations, this will fire again -- This is why we remove the handle later. This would use too much data
        let handle = circleQuery.observe(.documentEntered, with: { (key: String?, location: CLLocation?) in
            // key = user id, location = user's location
            // Load each user corresponding to each document key
            let userDocRef = FirestoreService.shared.userColRef.document(key!)
            
            userDocRef.getDocument { (document, error) in
                if let document = document, let documentData = document.data() {
                    let nearbyUser = try! FirestoreDecoder().decode(User.self, from: documentData)
                    nearbyUser.ref = userDocRef
                    // Don't include ourself or repeated users
                    if UserDefaults.standard.string(forKey: "userPhoneID") != nearbyUser.phoneID &&
                        !self.nearbyUsers.contains(nearbyUser) {
                        self.nearbyUsers.append(nearbyUser)
                        print("\(nearbyUser.first)")
                    }
                } else {
                    print("Geoquery: Document for user key \(String(describing: key)) does not exist")
                }
                
                // Reload the tableView in the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        // Stop observing location changes after 1.0 seconds to limit database reads
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            circleQuery.removeObserver(withHandle: handle)
        }
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
        else if segueID == "ChatsToLogin" {
            UserDefaults.standard.removeObject(forKey: "userDocID")
            UserDefaults.standard.removeObject(forKey: "userPhoneID")
        }
    }
    
    @IBAction func unwindfromProfileViewController(segue:UIStoryboardSegue) {}
    
    
    
    
    
    
    
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
        cell?.distanceLabel.text = thisUser.distanceMetric                          // User should not hold their own distanceMetric string. Should be generated.
        cell?.greetingTagTextView.text = thisUser.greetingTag
        cell?.iconImageView.image = UIImage(named: thisUser.profileImageName)
        cell?.backgroundColor = cell!.read ? .clear : .orange
        return cell!
    }
    
    // Set the height of each of the rows
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // Selecting a table cell will transition the user into the chat room
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = nearbyUsers[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? ChatsTableViewCell
        cell?.read = true
        performSegue(withIdentifier: "ChatsToChatroom", sender: self)
    }
}
