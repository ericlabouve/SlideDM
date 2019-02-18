//
//  Service.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/17/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation

// Singleton that is used to store information and instances shared across the app.
class Service {
    static let shared = Service()
    
    // Will only need to obtain the user's location once upon startup
    var locationObtained = false
}
