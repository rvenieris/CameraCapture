//
//  ColorConversions.swift
//  CameraCapture
//
//  Created by Pedro Gomes on 29/11/24.
//

import Foundation
import CoreImage


import Foundation

// Higher-precision transformation matrices
let displayP3ToXYZMatrix: [[Double]] = [
    [0.486570948648216, 0.265667693169093, 0.198217285234362],
    [0.228974564069749, 0.691738521836506, 0.079286914093745],
    [0.000000000000000, 0.045113381858903, 1.043944368900976]
]

let xyzToDisplayP3Matrix: [[Double]] = [
    [2.493496911941425, -0.931383617919123, -0.402710784450717],
    [-0.829488969561574, 1.762664060318346, 0.023624685841943],
    [0.035845830243784, -0.076172389268041, 0.956884524007687]
]

// Function to linearize gamma-corrected RGB
func linearizeRGB(_ component: Double) -> Double {
    return component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
}

// Function to apply gamma correction to linear RGB
func applyGammaCorrection(_ component: Double) -> Double {
    return component <= 0.0031308 ? component * 12.92 : (1.055 * pow(component, 1.0 / 2.4)) - 0.055
}

// Function to apply a transformation matrix
func applyMatrix(_ matrix: [[Double]], vector: (x: Double, y: Double, z: Double)) -> (x: Double, y: Double, z: Double) {
    let x = matrix[0][0] * vector.x + matrix[0][1] * vector.y + matrix[0][2] * vector.z
    let y = matrix[1][0] * vector.x + matrix[1][1] * vector.y + matrix[1][2] * vector.z
    let z = matrix[2][0] * vector.x + matrix[2][1] * vector.y + matrix[2][2] * vector.z
    return (x, y, z)
}

// Convert from Display P3 to XYZ
func fromP3ColorToXYZ(p3Color: (red: Double,
                                green: Double,
                                blue: Double)) -> (x: Double, y: Double, z: Double)? {

    // Extract RGB components and linearize them
    let rLinear = linearizeRGB(Double(p3Color.red))
    let gLinear = linearizeRGB(Double(p3Color.green))
    let bLinear = linearizeRGB(Double(p3Color.blue))
    
    // Transform to XYZ using the matrix
    let xyz = applyMatrix(displayP3ToXYZMatrix, vector: (x: rLinear, y: gLinear, z: bLinear))
    return xyz
}

// Convert from XYZ to Display P3
func fromXYZToP3Color(x: Double, y: Double, z: Double) -> (red: Double,
                                                           green: Double,
                                                           blue: Double) {
    // Transform from XYZ to linear RGB using the inverse matrix
    let linearRGB = applyMatrix(xyzToDisplayP3Matrix, vector: (x: x, y: y, z: z))
    
    // Apply gamma correction to linear RGB values
    let red = applyGammaCorrection(linearRGB.x)
    let green = applyGammaCorrection(linearRGB.y)
    let blue = applyGammaCorrection(linearRGB.z)
    
    
    // Clamp the final gamma-encoded values to [0, 1] to ensure valid results
    return (red: Double(red),
                   green: Double(green),
                   blue: Double(blue))
}


// Apply clamping only at the display step
func clampToDisplayRange(rgb: (red: Double, green: Double, blue: Double)) -> (red: Double, green: Double, blue: Double) {
    return (
        red: max(0, min(1, rgb.red)),
        green: max(0, min(1, rgb.green)),
        blue: max(0, min(1, rgb.blue))
    )
}

func apply(filter: CIColor.ConversionFilter,
           to rgb: (red: Double, green: Double, blue: Double)) -> (red: Double, green: Double, blue: Double) {
    switch filter {
    case .enhanceLargestChannel:
        let enhancement: Double = 1.3
        let maxChannel = max(rgb.red, rgb.green, rgb.blue)
        
        // Add enhancement to the largest channel
        let newRGB = (
            red: rgb.red == maxChannel ? rgb.red * enhancement : rgb.red,
            green: rgb.green == maxChannel ? rgb.green * enhancement : rgb.green,
            blue: rgb.blue == maxChannel ? rgb.blue * enhancement : rgb.blue
        )
        return newRGB
    case .reduceSmallerChannels:
        let lambda: Double = 0.9
        let maxChannel = max(rgb.red, rgb.green, rgb.blue)
        
        // Add enhancement to the largest channel
        let newRGB = (
            red: rgb.red != maxChannel ? rgb.red * lambda : rgb.red * 1 / lambda,
            green: rgb.green != maxChannel ? rgb.green * lambda : rgb.green * 1 / lambda*0.9,
            blue: rgb.blue != maxChannel ? rgb.blue * lambda : rgb.blue * 1 / lambda
        )
        return newRGB
    case .favorGreen:
        let newRGB = (
            red: rgb.red*0.9,
            green: rgb.green*1.2,
            blue: rgb.blue*0.9
        )
        return newRGB
    case .none:
        // Return the RGB values unmodified
        return rgb
    }
}


extension CIColor {
    public enum ConversionFilter {
        case enhanceLargestChannel
        case reduceSmallerChannels
        case favorGreen
        case none
    }
    
    public convenience init(rgb: (red: Double,
                               green: Double,
                                  blue: Double), filter: ConversionFilter) {
        let clampped = apply(filter: filter, to: rgb) //clampToDisplayRange(rgb: rgb)
        let colorSpace = CGColorSpace(name: CGColorSpace.displayP3) ?? CGColorSpaceCreateDeviceRGB()
        self.init(red: clampped.red, green: clampped.green, blue: clampped.blue, colorSpace: colorSpace)!
    }
    
    
    
    func asTuple() -> (red: Double, green: Double, blue: Double) {
        return (red: self.red,  green: self.green,  blue: self.blue)
    }
}
