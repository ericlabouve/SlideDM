//
//  Service.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/17/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation
import CoreLocation

import Firebase // Will need to be refactored into FirestoreService

// Singleton that is used to store information and instances shared across the app.
class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    var locationListeners = [UserLocationListener?]()
    
    // Location tracking
    var locationManager = CLLocationManager()
    
    // The user's current location which is fetched when the app is launched
    var userLocation: CLLocation? {
        // Notify all listeners
        didSet {
            print("userLocation set")
            for listener in locationListeners {
                listener?.userLocationChanged(userLocation: userLocation)
            }
        }
    }

    
    // Initiate location manager
    // Get the user's current location
    override private init() {
        super.init()
        // Get the user's location if we are authorized to do so AND if have not
        // requested their location during this app session
        if CLLocationManager.locationServicesEnabled() {
            print("Location Services Enabled")
            // Ask permission to obtain user's location
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.updateLocation()
        }
        print("LocationService Singleton Initialized")
    }
    
    
    
    
    // MARK: - Core Location
    
    // LocationManager:didUpdateLocations gets updated super quickly. So fast that by the time we call
    // stopUpdatingLocation it gets called again. We only want the user's location to get updated once.
    var calledOnce = false
    
    func updateLocation() {
        calledOnce = false
        self.locationManager.startUpdatingLocation()
    }
    
    
    // Save the user's current location locally and also in Firestore
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !calledOnce {
            calledOnce = true
            let userLocation:CLLocation = locations[0] as CLLocation
            print("locations = \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
            // Stop listening for location updates.
            manager.stopUpdatingLocation()
            // Globally set user position
            LocationService.shared.userLocation = userLocation
            updateCurrentLocationInFirestore()
        }
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
    
    // Those who implement UserLocationListener should call this and pass self
    func addLocationListener(listener: UserLocationListener) {
        locationListeners.append(listener)
    }
}

// Conform to this protocol if you want to receive updates when the user's location changes
protocol UserLocationListener {
    func userLocationChanged(userLocation: CLLocation?)
}
