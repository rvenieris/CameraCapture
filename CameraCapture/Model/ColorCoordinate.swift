//
//  ColorList.swift
//  CameraCapture
//
//  Created by Pedro Gomes on 26/11/24.
//

import Foundation
import UIKit

struct ColorCoordinate {
    var wavelength: Int
    var x: Double
    var y: Double
    var z: Double
    var x10: Double
    var y10: Double
    
    static func euclideanDistance(from color1: (x: Double, y: Double, z: Double), to color2: ColorCoordinate) -> Double {
        let distance = sqrt(pow(color1.x - color2.x, 2) + pow(color1.y - color2.y, 2) + pow(color1.z - color2.z, 2))
        return distance
    }

    static func findClosestWavelength(for color: (x: Double, y: Double, z: Double)) -> ColorCoordinate {
        let colorCoordinates = ColorCoordinate.colorCoordinates
        var closestWavelength = colorCoordinates[0]
        var smallestDistance = ColorCoordinate.euclideanDistance(from: color, to: colorCoordinates[0])
        
        for colorCoordinate in colorCoordinates {
            let distance = ColorCoordinate.euclideanDistance(from: color, to: colorCoordinate)
            if distance < smallestDistance {
                smallestDistance = distance
                closestWavelength = colorCoordinate
            }
        }
        
        return closestWavelength
    }
 
    
    /// Generate a custom spectrum based on a color coordinate array
    static func generateCustomSpectrumImage(size: CGSize, colorCoordinates: [ColorCoordinate], width: CGFloat = 1) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
            let _ = CGColorSpaceCreateDeviceRGB()
            
            let colorCoordinates = colorCoordinates
            
            var ciColors: [CIColor] = []
            for i in 0..<colorCoordinates.count {
                
//                if let ciColor = fromXYZToP3Color(x: colorCoordinates[i].x, y: colorCoordinates[i].y, z: colorCoordinates[i].z) {
//                    ciColors.append(ciColor)
//                }
            }
        
        let img = ciColors.uiImageWall() ?? UIImage()
        
        return img
    }
    
    /// Generates the traditional visual spectrum
    static func generateVisualSpectrumImage(size: CGSize) -> UIImage {
        
        let colorCoordinates = colorCoordinates
        
        var ciColors: [CIColor] = []
        for i in 0..<colorCoordinates.count {
            let ciColor = fromXYZToP3Color(x: colorCoordinates[i].x, y: colorCoordinates[i].y, z: colorCoordinates[i].z)
            ciColors.append(CIColor(rgb: ciColor))
            
        }
        let img = ciColors.uiImageWall() ?? UIImage()
        
        return img
    }
}




/// Test view controller to check visible spectrum
class XYZViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an ImageView
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        imageView.image = ColorCoordinate.generateVisualSpectrumImage(size: view.bounds.size)
    }
        
}




