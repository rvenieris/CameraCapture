//
//  TestViewController.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 15/11/24.
//

import UIKit

class TestViewController: UIViewController {
    
    
    var referenceImage: CIImage?
    /// UI that represents the reference line for the image capture
    let referenceLine = UIView()
    /// UI of a small visualization of the reference line for image capturing. Useful for after first capture.
    let referenceLineMiniMap = UIView()
    /// UI that controls what angle of capture
    let rotationSlider = UISlider()
    let captureButton = UIButton(type: .system)
    var referenceImageView: UIImageView!
    /// UI of a small visualization of the reference image. Useful for after first capture.
    let miniMap = UIImageView()
    /// UI that stores the result of the captured line image
    var captureImageView: UIImageView? = nil
    
    let exportButton = UIButton(type: .system)
    
    /// <#Description#>
    /// - Parameter animated: True of false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Carregar e processar a imagem DNG
        guard let ciImage = CIImage(forResource: "Teste3", withExtension: "DNG") else {
            print("Falha ao carregar ou processar a imagem DNG.")
            return
        }
        
        referenceImage = ciImage
        
        createReferenceImageView()
        
        createCaptureLine(line: referenceLine, parent: view)
        
        createCaptureButton()
        
        createExportButton()
        
        createRotationSlider()
        
        createImageMiniMap()
        
    }
    
    // MARK: - UI Views
    
    private func createReferenceImageView() {
        
        guard let referenceImage else {return}
        
        let image = UIImage(ciImage: referenceImage)
        
        referenceImageView = newImageView()
        
        view.addSubview(referenceImageView)
        referenceImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            referenceImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            referenceImageView.topAnchor.constraint(equalTo: view.topAnchor),
            referenceImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            referenceImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
        referenceImageView.image = image
    }
    
    private func createImageMiniMap() {
        
        guard let referenceImage else {return}
        
        miniMap.translatesAutoresizingMaskIntoConstraints = false
        miniMap.contentMode = .scaleAspectFit
        view.addSubview(miniMap)
        miniMap.layer.borderWidth = 1
        miniMap.layer.borderColor = UIColor.white.cgColor
        let ratio = referenceImage.extent.width / referenceImage.extent.height
        let miniMapHeight: CGFloat = 120
        NSLayoutConstraint.activate([
            miniMap.heightAnchor.constraint(equalToConstant: miniMapHeight),
            miniMap.widthAnchor.constraint(equalToConstant: miniMapHeight * ratio),
            miniMap.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            miniMap.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
        
        let image = UIImage(ciImage: referenceImage)
        miniMap.image = image
        
        createCaptureLine(line: referenceLineMiniMap, parent: miniMap, lineHeight: 0.8)
    }
    
    private func newImageView(height:CGFloat? = nil) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                  width: view.bounds.width,
                                                  height: height ?? view.bounds.height))
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        return imageView
    }
    
    private func solidView(color:UIColor)->UIView {
        let view = UIView(frame: view.frame)
        view.backgroundColor = color
        view.snapshotView(afterScreenUpdates: true)
        return view
    }
    
    
    private func createCaptureButton() {
        
        captureButton.setTitle("Capturar", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.layer.cornerRadius = 10
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            captureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 100),
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        captureButton.addTarget(self, action: #selector(captureFrequency), for: .touchUpInside)
    }
    
    private func createExportButton() {
        exportButton.setTitle("Exportar", for: .normal)
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.backgroundColor = .systemBlue
        exportButton.layer.cornerRadius = 10
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(exportButton)
        
        NSLayoutConstraint.activate([
            exportButton.trailingAnchor.constraint(equalTo: captureButton.trailingAnchor),
            exportButton.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            exportButton.widthAnchor.constraint(equalToConstant: 100),
            exportButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        exportButton.addTarget(self, action: #selector(exportToFrequency), for: .touchUpInside)
        
        exportButton.isEnabled = false
        exportButton.alpha = 0.3
    }
    
    
    private func createCaptureLine(line: UIView, parent: UIView, lineHeight: CGFloat = 1.5) {
        
        line.backgroundColor = .white
    
        line.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(line)
        
        NSLayoutConstraint.activate([
            line.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            line.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            line.widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: 1.5),
            line.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        parent.clipsToBounds = true
    }
    
    
    private func createRotationSlider() {
        rotationSlider.minimumValue = 0
        rotationSlider.maximumValue = 180
        rotationSlider.value = 0 // Start with no rotation
        rotationSlider.translatesAutoresizingMaskIntoConstraints = false
        rotationSlider.addTarget(self, action: #selector(rotateLine), for: .valueChanged)
        view.addSubview(rotationSlider)
        
        NSLayoutConstraint.activate([
            rotationSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            rotationSlider.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            rotationSlider.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor, constant: -40)
        ])
    }
    
    // MARK: - UI Actions
    
    @objc func rotateLine() {
        let angle = CGFloat(rotationSlider.value) * .pi / 180 // Convert degrees to radians
        referenceLine.transform = CGAffineTransform(rotationAngle: angle)
        referenceLineMiniMap.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    
    func rotateAndPreserveSize(_ image: CIImage, by radians: CGFloat, originalSize: CGFloat = 4032) -> CIImage {
        // Calculate the diagonal length to ensure the rotated image fits within the original size
        let diagonal = sqrt(pow(originalSize, 2) + pow(originalSize, 2))
        let scale = originalSize / diagonal

        // Create a rotation transform
        let rotation = CGAffineTransform(rotationAngle: radians)
        
        // Create a scaling transform
        let scaling = CGAffineTransform(scaleX: scale, y: scale)
        
        // Combine transforms: scale first, then rotate
        let combinedTransform = scaling.concatenating(rotation)

        // Apply the transform to the CIImage
        return image.transformed(by: combinedTransform)
    }
    
    var capturedColors: [CIColor]? = nil
    @objc func captureFrequency() {
        
        guard let referenceImage else { return }
        exportButton.isEnabled = true
        exportButton.alpha = 1.0
        
        let angle = CGFloat(rotationSlider.value) * .pi / 180
        let capturedImage = rotateAndPreserveSize(referenceImage, by: angle, originalSize: referenceImage.extent.width)
        
        referenceImageView.transform = CGAffineTransform(rotationAngle: -angle)
        print(referenceImage.extent.width)
        let colors = capturedImage.centralLineColors()
        self.capturedColors = colors
        
        let wallSize = view.bounds.height
        let colorWall = colors.uiImageWall(height: wallSize)
        
        let maxColors = colors.filter {$0.red == 1 || $0.green == 1 || $0.blue == 1 }
        print("Cores: \(maxColors.count)")
        maxColors.forEach {print($0.red, $0.green, $0.blue)}
        
        captureImageView?.removeFromSuperview()
        
        captureImageView = newImageView(height: wallSize)
        captureImageView?.image = colorWall
        view.insertSubview(captureImageView!, aboveSubview: referenceImageView)
    }
    
    
    @objc func exportToFrequency() {
        guard let capturedColors else { return }
        print(capturedColors[0])
        
        // Apply filter
        let filteredColors = capturedColors.map({CIColor(rgb: $0.asTuple(), filter: .none)})
        
        let xyzColors = filteredColors.compactMap({fromP3ColorToXYZ(p3Color: $0.asTuple())})
        
        // test conversion to XYZ:
        
        // -- For Testing
//        let backToColor = xyzColors.compactMap({fromXYZToP3Color(x: $0.x, y: $0.y, z: $0.z)})
//        let ciColors = backToColor.map({CIColor(rgb: $0, filter: .reduceSmallerChannels)})
//        captureImageView?.image = ciColors.uiImageWall(height: view.bounds.height)
//        return
        //  -- End For Testing
        
        let mappedColors = xyzColors.map({ColorCoordinate.findClosestWavelength(for: $0)})
        
        // -- For Testing
        let wavelengthColors = mappedColors.map { xyz in
            let rgb = fromXYZToP3Color(x: xyz.x, y: xyz.y, z: xyz.z)
            return CIColor(rgb: rgb, filter: .none)
        }
        captureImageView?.image = wavelengthColors.uiImageWall()
        // -- End For Testing
        
        let wavelengths = mappedColors.map({$0.wavelength})
        
        // TODO: - retornar isso ou exportar como grafico, entender o que fazer.
        print(wavelengths)
        
    }
}




/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


