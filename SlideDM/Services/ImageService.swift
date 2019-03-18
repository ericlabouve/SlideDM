//
//  ImageService.swift
//  SlideDM
//
//  Created by Eric LaBouve on 3/18/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    static let profileImageWidth = 150
    static let profileImageHeight = 150
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

extension UIImage {
    
    static func generateRandomGradientProfileImage() -> UIImage {
        var colors = [CGColor]()
        var locations = [NSNumber]()
        var counter = 0.0
        let numColors = 5
        for _ in 0..<numColors {
            colors.append(UIColor.random().cgColor)
            counter += 1.0/Double(numColors)
            locations.append(NSNumber(value: counter))
        }
        let startPoint = CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
        let endPoint = CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
        return UIImage.gradientImage(colors: colors, startPoint: startPoint, endPoint: endPoint, locations: locations)
    }
    
    // Input is a list of colors,
    // optional direction composed of a start point and an end point,
    // optional parameter for locations where the colors should start changing colors
    // optional parameter for size which is set to profileImageWidth/Height
    static func gradientImage(colors: [CGColor],
                              startPoint: CGPoint? = nil,
                              endPoint: CGPoint? = nil,
                              locations: [NSNumber]? = nil,
                              bounds: CGRect = CGRect(x: 0, y: 0, width: ImageService.profileImageWidth, height: ImageService.profileImageHeight)) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        if let startPoint = startPoint {
            gradientLayer.startPoint = startPoint
        }
        if let endPoint = endPoint {
            gradientLayer.endPoint = endPoint
        }
        if let locations = locations {
            gradientLayer.locations = locations
        }
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UIImageView {
    // Rounds out the ImageView's corners and adds a white border
    func rounded() {
        self.layer.cornerRadius = self.frame.height/10
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.white.cgColor
    }
}
