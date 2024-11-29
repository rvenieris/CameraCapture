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
 
    
    /// Generates the traditional visual spectrum
    static func generateVisualSpectrumImage(size: CGSize) -> UIImage {
        
        let colorCoordinates = colorCoordinates
        
        var ciColors: [CIColor] = []
        for i in 0..<colorCoordinates.count {
            let ciColor = fromXYZToP3Color(x: colorCoordinates[i].x, y: colorCoordinates[i].y, z: colorCoordinates[i].z)
            ciColors.append(CIColor(rgb: ciColor, filter: .none))
            
        }
        let img = ciColors.uiImageWall() ?? UIImage()
        
        return img
    }
    

    func colorFromWavelength() -> CIColor? {
        switch self.wavelength {
        case 380..<450: // Violet
            return CIColor(red: 0.56, green: 0.0, blue: 1.0)
        case 450..<485: // Blue
            return CIColor(red: 0.0, green: 0.0, blue: 1.0)
        case 485..<500: // Cyan
            return CIColor(red: 0.0, green: 1.0, blue: 1.0)
        case 500..<565: // Green
            return CIColor(red: 0.0, green: 1.0, blue: 0.0)
        case 565..<590: // Yellow
            return CIColor(red: 1.0, green: 1.0, blue: 0.0)
        case 590..<625: // Orange
            return CIColor(red: 1.0, green: 0.5, blue: 0.0)
        case 625..<750: // Red
            return CIColor(red: 1.0, green: 0.0, blue: 0.0)
        case ..<380: // Ultra-Violet
            return CIColor.black // Arbitrary for UV
        case 750...: // Infra-Red
            return CIColor.black // Arbitrary for IR
        default:
            return CIColor.black // No valid color
        }
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




