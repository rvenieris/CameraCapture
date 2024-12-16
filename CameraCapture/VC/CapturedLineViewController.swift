//
//  CapturedLineViewController.swift
//  CameraCapture
//
//  Created by Pedro Gomes on 16/12/24.
//

import UIKit

class CapturedLineViewController: UIViewController {
    
    
    /// UI that stores the result of the captured line image
    var captureImageView: UIImageView? = nil
    
    var referenceImage: CIImage?
    
    let exportButton = UIButton(type: .system)
    
    var capturedColors: [CIColor]? = nil
    
    var calibrationLineBlue: CalibrationLine?
    var calibrationLineRed: CalibrationLine?
    
    init(capturedColors: [CIColor]?) {
        super.init(nibName: nil, bundle: nil)
        self.capturedColors = capturedColors
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createImageWall()
        createCalibrationLines()
        createExportButton()
        createDismissButton()
    }
    
    private func createImageWall() {
        guard let colors = capturedColors else {return}
        
        let wallSize = view.bounds.height
        let colorWall = colors.uiImageWall(height: wallSize)
        captureImageView = newImageView(height: wallSize)
        captureImageView?.image = colorWall
        view.addSubview(captureImageView!)
        
    }
    
    private func createCalibrationLines() {
        // Add a blue calibration line
        calibrationLineBlue = CalibrationLine(color: .blue, wavelength: "402", initialX: 100, frameHeight: view.bounds.height)
        view.addSubview(calibrationLineBlue!)
        
        // Add a red calibration line
        calibrationLineRed = CalibrationLine(color: .red, wavelength: "600", initialX: 300, frameHeight: view.bounds.height)
        view.addSubview(calibrationLineRed!)
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
    
    private func createDismissButton() {
        // Create the button
        let dismissButton = UIButton(type: .system)
        
        // Set the down arrow symbol
        let arrowImage = UIImage(systemName: "x.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        dismissButton.setImage(arrowImage, for: .normal)
        dismissButton.tintColor = .white.withAlphaComponent(0.85)
        
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        // Add constraints for positioning
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dismissButton.widthAnchor.constraint(equalToConstant: 35),
            dismissButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        // Add the action to dismiss the view controller
        dismissButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
    }
    
    
    private func createExportButton() {
        exportButton.setTitle("Calcular", for: .normal)
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.backgroundColor = .systemBlue
        exportButton.layer.cornerRadius = 10
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(exportButton)
        
        NSLayoutConstraint.activate([
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exportButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            exportButton.widthAnchor.constraint(equalToConstant: 80),
            exportButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        exportButton.addTarget(self, action: #selector(exportToFrequency), for: .touchUpInside)
    }
    
    // MARK: - IB Actions
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func exportToFrequency() {
        guard let capturedColors else { return }
        
        guard let blueLine = calibrationLineBlue, let redLine = calibrationLineRed else { return }
        
        print(blueLine.getPosition())
        print(redLine.getPosition())
        
        // Apply filter
        let filteredColors = capturedColors.map({CIColor(rgb: $0.asTuple(), filter: .favorGreen)})
        
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





/// Calibration Line: cria linhas de calibração para a imagem capturada.
class CalibrationLine: UIView {
    // MARK: - Properties
    private let lineColor: UIColor
    private var wavelength: String
    private let label = UITextField()  // Editable label
    private let lineWidth: CGFloat = 1.0
    private let handleSize = CGSize(width: 40, height: 20)
    
    private let lineView = UIView() // Narrow line
    private let handle = UIView()   // Handle for dragging
    
    // MARK: - Initializer
    init(color: UIColor, wavelength: String, initialX: CGFloat, frameHeight: CGFloat) {
        self.lineColor = color
        self.wavelength = wavelength
        // Width matches the handle for better interaction
        let viewWidth = handleSize.width
        super.init(frame: CGRect(x: initialX, y: 0, width: viewWidth, height: frameHeight))
        setupLine()
        setupEditableLabel()
        setupHandle()
        addPanGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupLine() {
        // Line is a narrow subview inside CalibrationLine
        let lineX = (bounds.width - lineWidth) / 2 // Center the line horizontally
        lineView.frame = CGRect(x: lineX, y: 0, width: lineWidth, height: bounds.height)
        lineView.backgroundColor = lineColor
        addSubview(lineView)
    }
    
    private func setupEditableLabel() {
        // Configure the label as a text field
        label.text = wavelength
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
        label.borderStyle = .none
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.delegate = self
        label.keyboardType = .numberPad
        label.addDoneCancelToolbar()

        // Set a fixed width and height for the label and center it in the view
        label.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 5) // Centralized on the line
        
        addSubview(label)

        // Add tap gesture to begin editing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startEditingLabel))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
    }
    
    private func setupHandle() {
        // Handle positioned at the bottom of the CalibrationLine
        handle.frame = CGRect(x: (bounds.width - handleSize.width) / 2,
                              y: bounds.height - handleSize.height*3,
                              width: handleSize.width, height: handleSize.height)
        handle.backgroundColor = lineColor
        handle.layer.cornerRadius = 5
        handle.layer.borderWidth = 1
        handle.layer.borderColor = UIColor.white.cgColor
        handle.isUserInteractionEnabled = true
        
        // "< >" indicator
        let handleLabel = UILabel(frame: handle.bounds)
        handleLabel.text = "< >"
        handleLabel.textAlignment = .center
        handleLabel.textColor = .white
        handleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        handle.addSubview(handleLabel)
        
        addSubview(handle)
    }
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Public Methods
    public func getPosition() -> CGFloat {
        return self.lineView.frame.midX
    }
    
    // MARK: - Gesture Handler
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        let translation = gesture.translation(in: superview)
        
        // Update the position of the entire CalibrationLine
        var newX = center.x + translation.x
        newX = max(0, min(superview.bounds.width, newX)) // Keep within bounds
        center.x = newX
        
        // Reset gesture translation
        gesture.setTranslation(.zero, in: superview)
    }
    
    @objc private func startEditingLabel() {
        label.becomeFirstResponder() // Make the text field active for editing
    }
}

// MARK: - UITextFieldDelegate
extension CalibrationLine: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // End editing when the return key is pressed
        textField.resignFirstResponder()
        if let newText = textField.text, !newText.isEmpty {
            wavelength = newText
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let newText = textField.text, !newText.isEmpty {
            wavelength = newText
        }
    }
}
