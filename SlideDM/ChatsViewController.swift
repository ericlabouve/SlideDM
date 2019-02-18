//
//  ChatsViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// TODO: Refactor everything into a singleton

import UIKit
import Geofirestore
import Firebase
import CoreLocation

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    // User Interface
    @IBOutlet weak var tableView: UITableView!
    
    // Meta Data
    // Maintain this list for the TableView
    var nearbyUsers = [User]()
    
    // Firestore
    // Geofirestore
    let geoFireStorePath = "geoFirestore"
    var geoFirestoreRef: CollectionReference!
    var geoFirestore: GeoFirestore!
    
    // Storage
    var userDefaults = UserDefaults.standard
    
    // Location tracking
    let locationManager = CLLocationManager()
    
    // View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Firestore and Geofirestore
        if geoFirestore == nil {
            geoFirestoreRef = Firestore.firestore().collection(geoFireStorePath)
            geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
            updateCurrentLocation()
        }
        
        
        // Get the user's location if we are authorized to do so AND if have not
        // requested their location during this app session
        if CLLocationManager.locationServicesEnabled() && !Service.shared.locationObtained {
            // Ask permission to obtain user's location
            self.locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

        let fakeUser1 = User(first: "Eric", last: "LaBouve", phoneID: "123456789")
        let fakeUser2 = User(first: "Stephanie", last: "LaBouve", phoneID: "987654321")
        nearbyUsers.append(fakeUser1)
        nearbyUsers.append(fakeUser2)
    }
    
    
    // MARK: - Geofirestore Methods
    func updateCurrentLocation() {
        if let userDocID = userDefaults.object(forKey: "userDocID") as? String {
            geoFirestore.setLocation(location: CLLocation(latitude: 37.7853889, longitude: -122.4056973), forDocumentWithID: userDocID) { (error) in
                if (error != nil) {
                    print("An error occured: \(String(describing: error))")
                } else {
                    print("Saved location successfully!")
                }
            }
        } else {
            print("An error occured in updateCurrentLocation - No userDocID found in UserDefaults.")
        }
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
/*    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    
    // MARK: - Core Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("locations = \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
        // Stop listening for location updates
        manager.stopUpdatingLocation()
        Service.shared.locationObtained = true
    }

}
