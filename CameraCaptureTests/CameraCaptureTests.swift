//
//  CameraCaptureTests.swift
//  CameraCaptureTests
//
//  Created by Ricardo Almeida Venieris on 30/09/24.
//

import Testing
import UIKit

@testable import CameraCapture

struct CameraCaptureTests {
    
    let THRESHOLD = 0.025 // 2.5% threshold acceptance
    let MAX_NUMERICAL_ERROR = 0.00001


    // Error calculation
    func calculateError(original: (x: Double, y: Double, z: Double), reconverted: (x: Double, y: Double, z: Double)) -> (xError: Double, yError: Double, zError: Double) {
        let xError = abs(original.x - reconverted.x) / original.x * 100
        let yError = abs(original.y - reconverted.y) / original.y * 100
        let zError = abs(original.z - reconverted.z) / original.z * 100
        return (xError, yError, zError)
    }
    
    @Test func testConversionRoundXYZ() async throws {
        let allColors = ColorCoordinate.colorCoordinates
        
        let xyzColors = allColors.map({(x: $0.x, y: $0.y, z: $0.z)})
        
        for xyz in xyzColors {
            let convertedP3 = fromXYZToP3Color(x: xyz.x, y: xyz.y, z: xyz.z)
            
            let reconvertedXYZ = fromP3ColorToXYZ(p3Color: convertedP3)
            assert(reconvertedXYZ != nil)
            
            print(xyz, reconvertedXYZ!)
            print(calculateError(original: xyz, reconverted: reconvertedXYZ!))
            
            // assert if they are different by a threshold
            assert(abs(xyz.x - reconvertedXYZ!.x) <= THRESHOLD)
            
            assert(abs(xyz.y - reconvertedXYZ!.y) <= THRESHOLD)
            
            assert(abs(xyz.z - reconvertedXYZ!.z) <= THRESHOLD)
            
        }
    }
    
    // Function to multiply two 3x3 matrices
    private func multiplyMatrices(_ m1: [[Double]], _ m2: [[Double]]) -> [[Double]] {
        var result = Array(repeating: Array(repeating: 0.0, count: 3), count: 3)
        for i in 0..<3 {
            for j in 0..<3 {
                result[i][j] = m1[i][0] * m2[0][j] + m1[i][1] * m2[1][j] + m1[i][2] * m2[2][j]
            }
        }
        return result
    }

    private func validateMatrices(threshold: Double) -> Bool {
        let identityMatrix = multiplyMatrices(displayP3ToXYZMatrix, xyzToDisplayP3Matrix)
        print("Validation Matrix (should be close to Identity):")
        for (idx, row) in identityMatrix.enumerated() {
            print(row)
            for (jdx, elem) in row.enumerated() {
                let subtraction: Double = idx == jdx ? 1.0 : 0.0
                if abs(elem - subtraction) > threshold {
                        return false
                }
                
            }
        }
        return true
    }
    
    /// Validate if the matrices satisfy M * M^-1 = I
    @Test func testConversionMatrices() async throws {
        let validation = validateMatrices(threshold: MAX_NUMERICAL_ERROR)
        assert(validation)
    }
    
    
    @Test func testConversionRoundP3() async throws {
    
        let rgbOriginal = (red: 0.95, green: 0.352, blue: 0.352) // Bright orange
        
        guard let convertedXYZ = fromP3ColorToXYZ(p3Color: rgbOriginal) else {return}
        
        
        let reconvertedRGB = fromXYZToP3Color(x: convertedXYZ.x, y: convertedXYZ.y, z: convertedXYZ.z)
        
        // assert if they are different by a threshold
        assert(abs(reconvertedRGB.red - rgbOriginal.red) <= THRESHOLD )
        
        assert(abs(reconvertedRGB.green - rgbOriginal.green) <= THRESHOLD)
        
        assert(abs(reconvertedRGB.blue - rgbOriginal.blue) <= THRESHOLD)
            
        
    }

}
