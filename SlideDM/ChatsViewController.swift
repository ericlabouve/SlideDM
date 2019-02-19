//
//  ChatsViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// Architecture
// How to observe --> call loadNearbyUsers()
// load singleton
// get user from id

import UIKit
import CoreLocation
import Firebase

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LocationListener { //}, CLLocationManagerDelegate {
    // User Interface
    @IBOutlet weak var tableView: UITableView!
    
    // Meta Data
    // Maintain this list for the TableView
    var nearbyUsers = [User]()
    
    // Storage
    var userDefaults = UserDefaults.standard
    
    
    
    
    func locationChanged(userLocation: CLLocation?) {
        // Update table
        print("Here is the user location: \(userLocation)")
    }
    
    
    
    
    // View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure we load our location ahead of time
//        LocationService.shared.load()
        
//        LocationService.shared.locationListener = self
        LocationService.shared.addLocationListener(obj: self)

        let fakeUser1 = User(first: "Eric", last: "LaBouve", phoneID: "123456789")
        let fakeUser2 = User(first: "Stephanie", last: "LaBouve", phoneID: "987654321")
        nearbyUsers.append(fakeUser1)
        nearbyUsers.append(fakeUser2)
    }
    
    @IBAction func loadContactsButton(_ sender: UIButton) {
        if let center = LocationService.shared.userLocation {
            // 5 miles = 8.04672 kilometers
            var circleQuery = FirestoreService.shared.geoFirestore.query(withCenter: center, radius: 8.04672)
            
            // Refactor this into FirestoreService later
            circleQuery.observe(.documentEntered, with: { (key: String?, location: CLLocation?) in
                // key contains our user id
                
                // Load each user corresponding to each document key
                //Firestore.firestore().collection("users/").whereField("", isEqualTo: key!)
            })
            
        }
    }
    
    // Loads all users from firestore
    func loadNearbyUsers() {
        
        // THIS IS REALLY BAD BUT IDK HOW ELSE TO MAKE SURE THE USER'S LOCATION IS SET
//        while LocationService.shared.userLocation == nil {
//            // Wait until app has located itself
//        }
        
        if let center = LocationService.shared.userLocation {
            // 5 miles = 8.04672 kilometers
            var circleQuery = FirestoreService.shared.geoFirestore.query(withCenter: center, radius: 8.04672)
            

        } else {
            print("user Location not yet ready")
        }
    }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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

}
