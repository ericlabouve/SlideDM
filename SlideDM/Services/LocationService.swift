//
//  Service.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/17/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation
import CoreLocation

// Singleton that is used to store information and instances shared across the app.
class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    // Location tracking
    var locationManager = CLLocationManager()
    
    // The user's current location which is updated when the app is launched
    var userLocation: CLLocation?
    
    // Initiate location manager
    // Get the user's current location
    override private init() {
        super.init()
        // Get the user's location if we are authorized to do so AND if have not
        // requested their location during this app session
        if CLLocationManager.locationServicesEnabled() {
            // Ask permission to obtain user's location
            self.locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        print("LocationService Singleton Initialized")
    }
    
    // Empty body so that init is called
    func load() {}
    
    func isUserLocationSet() -> Bool {
        return LocationService.shared.userLocation != nil
    }
    
    
    // MARK: - Core Location
    
    // Save the user's current location locally and also in Firestore
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("locations = \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
        // Stop listening for location updates
        manager.stopUpdatingLocation()
        // Globally set user position
        LocationService.shared.userLocation = userLocation
        updateCurrentLocationInFirestore()
    }
    
    func updateCurrentLocationInFirestore() {
        if let userDocID = UserDefaults.standard.object(forKey: "userDocID") as? String, let location = LocationService.shared.userLocation {
            FirestoreService.shared.geoFirestore.setLocation(location: location, forDocumentWithID: userDocID) { (error) in
                if (error != nil) {
                    print("An error occured: \(String(describing: error))")
                } else {
                    print("Saved location in Firestore")
                }
            }
        } else {
            print("An error occured in updateCurrentLocation - No userDocID or location.")
        }
    }
}
