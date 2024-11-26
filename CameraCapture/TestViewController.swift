//
//  TestViewController.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 15/11/24.
//

import UIKit

class TestViewController: UIViewController {
    
    
    var referenceImage: CIImage?
    let referenceLine = UIView()
    let rotationSlider = UISlider()
    let captureButton = UIButton(type: .system)
    
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
        
        let image = UIImage(ciImage: ciImage)
        
        let imageView = newImageView()
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
        imageView.image = image
        
        
        createCaptureLine()
        
        createCaptureButton()
        
        createRotationSlider()
    }
    
    // MARK: - UI Views
    
    
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
    
    
    private func createCaptureLine() {
        
        referenceLine.backgroundColor = .white
        
        let lineHeight: CGFloat = 1.5
        referenceLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(referenceLine)
        
        NSLayoutConstraint.activate([
            referenceLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            referenceLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            referenceLine.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            referenceLine.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
    }
    
    
    private func createRotationSlider() {
        rotationSlider.minimumValue = 0
        rotationSlider.maximumValue = 360
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
    }
    
    @objc func captureFrequency() {
        
        guard let referenceImage else { return }
        
        let colors = referenceImage.centralLineColors()
        let wallSize = view.bounds.height/2.0
        let colorWall = colors.uiImageWall(height: wallSize)
        
        let maxColors = colors.filter {$0.red == 1 || $0.green == 1 || $0.blue == 1 }
        print("Cores: \(maxColors.count)")
        maxColors.forEach {print($0.red, $0.green, $0.blue)}
        
        let imageView3 = newImageView(height: wallSize)
        imageView3.image = colorWall
        view.addSubview(imageView3)
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


