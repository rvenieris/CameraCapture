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
    
    static let colorCoordinates: [ColorCoordinate] = [
        ColorCoordinate(wavelength: 380, x: 0.001368, y: 0.000039, z: 0.006450, x10: 0.17411, y10: 0.00496),
        ColorCoordinate(wavelength: 385, x: 0.002236, y: 0.000064, z: 0.010550, x10: 0.17401, y10: 0.00498),
        ColorCoordinate(wavelength: 390, x: 0.004243, y: 0.000120, z: 0.020050, x10: 0.17380, y10: 0.00492),
        ColorCoordinate(wavelength: 395, x: 0.007650, y: 0.000217, z: 0.036210, x10: 0.17356, y10: 0.00492),
        ColorCoordinate(wavelength: 400, x: 0.014310, y: 0.000396, z: 0.067850, x10: 0.17334, y10: 0.00480),
        ColorCoordinate(wavelength: 405, x: 0.023190, y: 0.000640, z: 0.110200, x10: 0.17302, y10: 0.00478),
        ColorCoordinate(wavelength: 410, x: 0.043510, y: 0.001210, z: 0.207400, x10: 0.17258, y10: 0.00480),
        ColorCoordinate(wavelength: 415, x: 0.077630, y: 0.002180, z: 0.371300, x10: 0.17209, y10: 0.00483),
        ColorCoordinate(wavelength: 420, x: 0.134380, y: 0.004000, z: 0.645500, x10: 0.17141, y10: 0.00510),
        ColorCoordinate(wavelength: 425, x: 0.214770, y: 0.007300, z: 1.039050, x10: 0.17030, y10: 0.00579),
        ColorCoordinate(wavelength: 430, x: 0.283900, y: 0.011600, z: 1.385600, x10: 0.16888, y10: 0.00690),
        ColorCoordinate(wavelength: 435, x: 0.328500, y: 0.016840, z: 1.622960, x10: 0.16690, y10: 0.00856),
        ColorCoordinate(wavelength: 440, x: 0.348280, y: 0.023000, z: 1.747060, x10: 0.16441, y10: 0.01086),
        ColorCoordinate(wavelength: 445, x: 0.348060, y: 0.029800, z: 1.782600, x10: 0.16110, y10: 0.01379),
        ColorCoordinate(wavelength: 450, x: 0.336200, y: 0.038000, z: 1.772110, x10: 0.15664, y10: 0.01770),
        ColorCoordinate(wavelength: 455, x: 0.318700, y: 0.048000, z: 1.744100, x10: 0.15099, y10: 0.02274),
        ColorCoordinate(wavelength: 460, x: 0.290800, y: 0.060000, z: 1.669200, x10: 0.14396, y10: 0.02970),
        ColorCoordinate(wavelength: 465, x: 0.251100, y: 0.073900, z: 1.528100, x10: 0.13550, y10: 0.03988),
        ColorCoordinate(wavelength: 470, x: 0.195360, y: 0.090980, z: 1.287640, x10: 0.12412, y10: 0.05780),
        ColorCoordinate(wavelength: 475, x: 0.142100, y: 0.112600, z: 1.041900, x10: 0.10959, y10: 0.08684),
        ColorCoordinate(wavelength: 480, x: 0.095640, y: 0.139020, z: 0.812950, x10: 0.09129, y10: 0.13270),
        ColorCoordinate(wavelength: 485, x: 0.057950, y: 0.169300, z: 0.616250, x10: 0.06871, y10: 0.20072),
        ColorCoordinate(wavelength: 490, x: 0.032010, y: 0.208020, z: 0.465180, x10: 0.04539, y10: 0.29498),
        ColorCoordinate(wavelength: 495, x: 0.014700, y: 0.258600, z: 0.353300, x10: 0.02346, y10: 0.41270),
        ColorCoordinate(wavelength: 500, x: 0.004900, y: 0.323300, z: 0.272000, x10: 0.00817, y10: 0.53842),
        ColorCoordinate(wavelength: 505, x: 0.002400, y: 0.407300, z: 0.212300, x10: 0.00386, y10: 0.65482),
        ColorCoordinate(wavelength: 510, x: 0.009300, y: 0.503300, z: 0.158000, x10: 0.01387, y10: 0.75019),
        ColorCoordinate(wavelength: 515, x: 0.029100, y: 0.608000, z: 0.111700, x10: 0.03885, y10: 0.81202),
        ColorCoordinate(wavelength: 520, x: 0.063270, y: 0.710000, z: 0.078250, x10: 0.07430, y10: 0.83334),
        ColorCoordinate(wavelength: 525, x: 0.109600, y: 0.793200, z: 0.057250, x10: 0.11416, y10: 0.82626),
        ColorCoordinate(wavelength: 530, x: 0.165500, y: 0.862000, z: 0.042160, x10: 0.15472, y10: 0.80581),
        ColorCoordinate(wavelength: 535, x: 0.225750, y: 0.914850, z: 0.029840, x10: 0.19288, y10: 0.78163),
        ColorCoordinate(wavelength: 540, x: 0.290400, y: 0.954000, z: 0.020300, x10: 0.22962, y10: 0.75433),
        ColorCoordinate(wavelength: 545, x: 0.359700, y: 0.980300, z: 0.013400, x10: 0.26578, y10: 0.72424),
        ColorCoordinate(wavelength: 550, x: 0.433450, y: 0.994950, z: 0.008750, x10: 0.30160, y10: 0.69231),
        ColorCoordinate(wavelength: 555, x: 0.512050, y: 1.000000, z: 0.005750, x10: 0.33736, y10: 0.65885),
        ColorCoordinate(wavelength: 560, x: 0.594500, y: 0.995000, z: 0.003900, x10: 0.37310, y10: 0.62445),
        ColorCoordinate(wavelength: 565, x: 0.678400, y: 0.978600, z: 0.002750, x10: 0.40874, y10: 0.58961),
        ColorCoordinate(wavelength: 570, x: 0.762100, y: 0.952000, z: 0.002100, x10: 0.44406, y10: 0.55471),
        ColorCoordinate(wavelength: 575, x: 0.842500, y: 0.915400, z: 0.001800, x10: 0.47877, y10: 0.52020),
        ColorCoordinate(wavelength: 580, x: 0.916300, y: 0.870000, z: 0.001650, x10: 0.51249, y10: 0.48659),
        ColorCoordinate(wavelength: 585, x: 0.978800, y: 0.816000, z: 0.001400, x10: 0.54479, y10: 0.45443),
        ColorCoordinate(wavelength: 590, x: 1.026300, y: 0.757000, z: 0.001100, x10: 0.57515, y10: 0.42423),
        ColorCoordinate(wavelength: 595, x: 1.056200, y: 0.694900, z: 0.000800, x10: 0.60293, y10: 0.39650),
        ColorCoordinate(wavelength: 600, x: 1.062200, y: 0.631900, z: 0.000800, x10: 0.62704, y10: 0.37249),
        ColorCoordinate(wavelength: 605, x: 1.045600, y: 0.566800, z: 0.000600, x10: 0.64823, y10: 0.35139),
        ColorCoordinate(wavelength: 610, x: 1.002000, y: 0.503000, z: 0.000340, x10: 0.66576, y10: 0.33401),
        ColorCoordinate(wavelength: 615, x: 0.938400, y: 0.441200, z: 0.000240, x10: 0.68008, y10: 0.31975),
        ColorCoordinate(wavelength: 620, x: 0.854450, y: 0.381000, z: 0.000190, x10: 0.69150, y10: 0.30834),
        ColorCoordinate(wavelength: 625, x: 0.751400, y: 0.321000, z: 0.000100, x10: 0.70061, y10: 0.29930),
        ColorCoordinate(wavelength: 630, x: 0.642400, y: 0.265000, z: 0.000050, x10: 0.70792, y10: 0.29203),
        ColorCoordinate(wavelength: 635, x: 0.541900, y: 0.217000, z: 0.000030, x10: 0.71403, y10: 0.28593),
        ColorCoordinate(wavelength: 640, x: 0.447900, y: 0.175000, z: 0.000020, x10: 0.71903, y10: 0.28093),
        ColorCoordinate(wavelength: 645, x: 0.360800, y: 0.138000, z: 0.000010, x10: 0.72303, y10: 0.27695),
        ColorCoordinate(wavelength: 650, x: 0.283500, y: 0.107000, z: 0.000000, x10: 0.72599, y10: 0.27401),
        ColorCoordinate(wavelength: 655, x: 0.218700, y: 0.081600, z: 0.000000, x10: 0.72827, y10: 0.27173),
        ColorCoordinate(wavelength: 660, x: 0.164900, y: 0.061000, z: 0.000000, x10: 0.72997, y10: 0.27003),
        ColorCoordinate(wavelength: 665, x: 0.121100, y: 0.044580, z: 0.000000, x10: 0.73109, y10: 0.26891),
        ColorCoordinate(wavelength: 670, x: 0.087000, y: 0.032000, z: 0.000000, x10: 0.73199, y10: 0.26801),
        ColorCoordinate(wavelength: 675, x: 0.063000, y: 0.023000, z: 0.000000, x10: 0.73272, y10: 0.26728),
        ColorCoordinate(wavelength: 680, x: 0.046770, y: 0.017000, z: 0.000000, x10: 0.73342, y10: 0.26658),
        ColorCoordinate(wavelength: 685, x: 0.032900, y: 0.011920, z: 0.000000, x10: 0.73405, y10: 0.26595),
        ColorCoordinate(wavelength: 690, x: 0.022700, y: 0.008210, z: 0.000000, x10: 0.73439, y10: 0.26561),
        ColorCoordinate(wavelength: 695, x: 0.015840, y: 0.005723, z: 0.000000, x10: 0.73459, y10: 0.26541),
        ColorCoordinate(wavelength: 700, x: 0.011359, y: 0.004102, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 705, x: 0.008111, y: 0.002929, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 710, x: 0.005790, y: 0.002091, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 715, x: 0.004109, y: 0.001484, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 720, x: 0.002899, y: 0.001047, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 725, x: 0.002049, y: 0.000740, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 730, x: 0.001440, y: 0.000520, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 735, x: 0.001000, y: 0.000361, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 740, x: 0.000690, y: 0.000249, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 745, x: 0.000476, y: 0.000172, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 750, x: 0.000332, y: 0.000120, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 755, x: 0.000235, y: 0.000085, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 760, x: 0.000166, y: 0.000060, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 765, x: 0.000117, y: 0.000042, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 770, x: 0.000083, y: 0.000030, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 775, x: 0.000059, y: 0.000021, z: 0.000000, x10: 0.73469, y10: 0.26531),
        ColorCoordinate(wavelength: 780, x: 0.000042, y: 0.000015, z: 0.000000, x10: 0.73469, y10: 0.26531)
    ]
}



/// Test view controller to check visible spectrum
class XYZViewController: UIViewController {
    override func viewDidLoad() {
            super.viewDidLoad()

            // Create an ImageView
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            imageView.contentMode = .scaleToFill
            view.addSubview(imageView)
            imageView.image = generateSpectrumImage()
        }
    
    func generateSpectrumImage() -> UIImage {
            let size = view.bounds.size
            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { ctx in
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                
                // Draw each segment based on the wavelengths
                let totalRange = 780.0 - 380.0 // from 380 nm to 780 nm
                let pixelPerNm = size.width / CGFloat(totalRange)
                
                let colorCoordinates = ColorCoordinate.colorCoordinates
                
                for i in 0..<colorCoordinates.count {
                    let wavelength = Double(colorCoordinates[i].wavelength)
                    let color = UIColor.fromXYZ(x: colorCoordinates[i].x, y: colorCoordinates[i].y, z: colorCoordinates[i].z)
                    ctx.cgContext.setFillColor(color.cgColor)
                    
                    let xPosition = pixelPerNm * CGFloat(wavelength - 380.0)
                    let width = i < colorCoordinates.count - 1 ? pixelPerNm * CGFloat(Double(colorCoordinates[i + 1].wavelength) - wavelength) : size.width - xPosition
                    
                    ctx.cgContext.fill(CGRect(x: xPosition, y: 0, width: width, height: size.height))
                }
            }
            
            return img
        }
        

    func createColorGradient() -> [CGColor] {
        var colors = [CGColor]()
        // Assuming 'colorCoordinates' array contains your color data
        for coordinate in ColorCoordinate.colorCoordinates {
            let color = UIColor.fromXYZ(x: coordinate.x, y: coordinate.y, z: coordinate.z)
            colors.append(color.cgColor)
        }
        return colors
    }
}

// Extension to convert XYZ color model to UIColor

extension UIColor {
    static func fromXYZ(x: Double, y: Double, z: Double) -> UIColor {
        // D65 white point
        let xD65 = 0.95047
        let yD65 = 1.00000
        let zD65 = 1.08883

        // Matrix conversion (sRGB D65)
        var r = 3.2406 * x - 1.5372 * y - 0.4986 * z
        var g = -0.9689 * x + 1.8758 * y + 0.0415 * z
        var b = 0.0557 * x - 0.2040 * y + 1.0570 * z

        // Perform gamma correction and clip the values
        r = clip(color: r)
        g = clip(color: g)
        b = clip(color: b)
        
        print(r, g, b)

        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    }

    // Helper function to clip and adjust colors
    static func clip(color: Double) -> Double {
        let color = max(min(color, 1.0), 0.0) // Clip between 0 and 1
        if color <= 0.0031308 {
            return 12.92 * color
        } else {
            return 1.055 * pow(color, 1 / 2.4) - 0.055 // Apply gamma correction
        }
    }
}