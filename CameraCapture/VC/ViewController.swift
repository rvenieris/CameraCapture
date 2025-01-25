//
//  ViewController2.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 30/09/24.
//

import UIKit
import AVFoundation
import Photos
import SwiftUI

class ViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var photoOutput: AVCapturePhotoOutput!
    var displayLayer: AVSampleBufferDisplayLayer!

    var isImageFrozen = false // Para controlar o estado de congelamento da imagem
    var histogramChannel:HistogramChannel = .all
    var currentCameraIndex = 0
    var availableVideoDevices: [AVCaptureDevice] = []
    
    var currentCamera:AVCaptureDevice { availableVideoDevices[currentCameraIndex] }
    
    
//    @State var flash = false
    // MARK: - Components
    lazy var torchButton: UIViewController = {
        UIHostingController(rootView: FlashlightView(torchButtonPressed: { [weak self] in
            self?.torchButtonPressed()
        }))
        
//        let torchButton = UIButton(type: .system, primaryAction: UIAction(handler: { [weak self] a in
//            self?.torchButtonPressed()
//        }))
//        torchButton.frame = CGRect(x: 20, y: 60, width: 100, height: 50)
//        
//        torchButton.configuration = .borderedTinted().updated(for: torchButton)
//        torchButton.tintColor = .green
//        // Imagem e título para o estado normal (lanterna desligada)
//        torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
//        torchButton.setTitle("Off", for: .normal)
//        torchButton.setTitleColor(.gray, for: .normal)
//
//        // Imagem e título para o estado selecionado (lanterna ligada)
//        torchButton.setImage(UIImage(systemName: "flashlight.on.fill"), for: .selected)
//        torchButton.setTitle(" On", for: .selected)
//        torchButton.setTitleColor(.white, for: .selected)
//        
//        torchButton.contentHorizontalAlignment = .center
//        torchButton.contentVerticalAlignment = .center
//        torchButton.imageView?.contentMode = .scaleAspectFit
//
//        torchButton.backgroundColor = .black.withAlphaComponent(0.5)
//        torchButton.layer.cornerRadius = 10
//
////        torchButton.addTarget(self, action: #selector(torchButtonPressed), for: .touchUpInside)
//        return torchButton
    }()

    lazy var switchButton: UIButton = {
        let menuButton = UIButton(configuration: .bordered())
        let switchButton = UIMenu(options: [.singleSelection], children: availableVideoDevices.enumerated().map { (index, ad) in
            UIAction(title: ad.localizedName) { [weak self] _ in
                self?.currentCameraIndex = index
            }
        })
        menuButton.setTitle(currentCamera.localizedName, for: .normal)
        menuButton.menu = switchButton
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.tintColor = .white
//        UIButton(type: .system)
//        menuButton.frame = CGRect(x: view.frame.width - 220, y: 60, width: 200, height: 50)
//        switchButton.setTitle(currentCamera.localizedName, for: .normal)
//        switchButton.setTitleColor(.white, for: .normal)
//        
//        switchButton.backgroundColor = .black.withAlphaComponent(0.5)
//        switchButton.layer.cornerRadius = 10
//
//        
//        switchButton.addTarget(self, action: #selector(switchCameraButtonPressed), for: .touchUpInside)
        return menuButton
    }()
    
    lazy var captureButton:UIButton = {
        let captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(x: (view.frame.width - 70)/2, y: view.frame.height - 100, width: 70, height: 70)
        captureButton.layer.cornerRadius = 35
        captureButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.setTitleColor(.blue, for: .selected)
        captureButton.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        return captureButton
    }()

    lazy var channelButton:UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: ((view.frame.width - 60)/2) - 100, y: view.frame.height - 100, width: 60, height: 60)
        button.layer.cornerRadius = 30
        button.backgroundColor = UIColor.gray
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.blue, for: .selected)
        button.addTarget(self, action: #selector(changeChannel), for: .touchUpInside)
        return button
    }()

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDisplayLayer()
        
        view.addSubview(captureButton)
        view.addSubview(channelButton)
        view.addSubview(switchButton)
        
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            switchButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        if currentCamera.hasTorch {
            addChild(torchButton)
            torchButton.view.isOpaque = false
            torchButton.view.backgroundColor = .clear
            view.addSubview(torchButton.view)
            torchButton.didMove(toParent: self)
            
            torchButton.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                torchButton.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                torchButton.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
                torchButton.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])
            
//            torchButton.view.frame = CGRect(x: 20, y: 60, width: 100, height: 50)
        }
    }

    // MARK: - Capture Session
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo // Usamos .photo para permitir a captura RAW

        // Listar dispositivos de vídeo disponíveis
        availableVideoDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: .allCameras, //[.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .],
            mediaType: .video,
            position: .back
        ).devices

        // Verificar se há dispositivos disponíveis
        guard !availableVideoDevices.isEmpty else {
            print("Não foram encontradas câmeras disponíveis.")
            return
        }

        // Configurar o dispositivo inicial
        configureInputDevice()

        // Configurar saída de vídeo
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        let videoQueue = DispatchQueue(label: "videoQueue")
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Configurar saída de foto
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.maxPhotoDimensions = photoOutput.maxPhotoDimensions
//            photoOutput.photoSettingsForSceneMonitoring = [.autoWhiteBalance]
            photoOutput.isAppleProRAWEnabled = photoOutput.availableRawPhotoPixelFormatTypes.count > 0
        }

        print("photoOutput.maxPhotoDimensions", photoOutput.maxPhotoDimensions)
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }

    func configureInputDevice() {
        // Remover todas as entradas atuais
        captureSession.beginConfiguration()
        if let currentInput = captureSession.inputs.first {
            captureSession.removeInput(currentInput)
        }

        // Obter o dispositivo atual
        do {
            let videoInput = try AVCaptureDeviceInput(device: currentCamera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Não foi possível adicionar o dispositivo de entrada.")
            }
        } catch {
            print("Erro ao configurar o dispositivo de entrada: \(error)")
        }

        captureSession.commitConfiguration()
    }
    
    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        displayLayer.frame = view.bounds
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            captureSession.connections.first!.videoOrientation = AVCaptureVideoOrientation.portrait;
        case .portraitUpsideDown:
            captureSession.connections.first!.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown;
        case .landscapeLeft:
            captureSession.connections.first!.videoOrientation = AVCaptureVideoOrientation.landscapeLeft;
        case .landscapeRight:
            captureSession.connections.first!.videoOrientation = AVCaptureVideoOrientation.landscapeRight;
        default:
            captureSession.connections.first!.videoOrientation = AVCaptureVideoOrientation.landscapeRight;
        }
    }
    
    
    func setupDisplayLayer() {
        displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.frame = view.bounds
        view.layer.addSublayer(displayLayer)
    }

    // MARK: - Actions
    @objc func captureButtonPressed() {
        if isImageFrozen {
            // Se a imagem estiver congelada, retomar o fluxo de vídeo
            isImageFrozen = false
        } else {
            // Capturar foto em formato DNG
            guard let rawFormatType = photoOutput.availableRawPhotoPixelFormatTypes.first else {
                print("Captura de foto RAW não suportada.")
                return
            }

            let photoSettings = AVCapturePhotoSettings(rawPixelFormatType: rawFormatType)

            // Ajustar dimensões máximas da foto
//            photoSettings.format = [
//                AVVideoCodecKey: AVVideoCodecType.hevc,
//                AVVideoWidthKey: photoOutput.maxPhotoDimensions.width,
//                AVVideoHeightKey: photoOutput.maxPhotoDimensions.height
//            ]

            photoOutput.capturePhoto(with: photoSettings, delegate: self)

            // Congelar a imagem na tela
            isImageFrozen = true
            
        }
        
        captureButton.isSelected = isImageFrozen
    }

    @objc func changeChannel() {
        histogramChannel = histogramChannel.next
        switch histogramChannel {
        case .red:
            channelButton.backgroundColor = .red
        case .green:
            channelButton.backgroundColor = .green
        case .blue:
            channelButton.backgroundColor = .blue
        case .all:
            channelButton.backgroundColor = .gray
        }
    }

    @objc func switchCameraButtonPressed() {
        // Alternar para a próxima câmera
        currentCameraIndex = (currentCameraIndex + 1) % availableVideoDevices.count

        // Reconfigurar o dispositivo de entrada
        configureInputDevice()
        switchButton.setTitle(currentCamera.localizedName, for: .normal)
    }
    
    @objc func torchButtonPressed() {
        do {
            try currentCamera.lockForConfiguration()
            currentCamera.torchMode = currentCamera.isTorchActive ? .off : .on
//            torchButton.tintColor = currentCamera.isTorchActive ? .red : .gray
        } catch {
            print("lockForConfiguration Error: \(error)")
        }
        currentCamera.unlockForConfiguration()
//        torchButton.isSelected.toggle()
    }
    
    func drawHorizontalLine(in context: CGContext, at y: CGFloat) {
        let lineWidth: CGFloat = 1.0
//        let lineColor: CGColor = UIColor.black.cgColor
        context.setLineDash(phase: 0.0, lengths: [lineWidth])
                                                  context.setLineDash(phase: 0.0, lengths: [lineWidth])
                                                  }

}

// MARK: - Sample Buffer Delegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
//        connection.videoRotationAngle = .portrait
//        connection.videoRotationAngle = .pi / 2
        
        guard !isImageFrozen else { return }
            // Enfileirar o sampleBuffer para exibição
        displayLayer.sampleBufferRenderer.enqueue(sampleBuffer)
    }
}

// MARK: - Photo Capture Delegate
extension ViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        if let error {
            print("Erro ao capturar foto: \(error)")
            return
        }

        guard let dngData = photo.fileDataRepresentation() else {
            print("Não foi possível obter os dados da foto.")
            return
        }

        // Salvar a foto em DNG no rolo da câmera
        saveDNGToCameraRoll(dngData)

        
        // Obter a imagem processada para gerar o histograma
        let img = photo.cgImageRepresentation()!
        let temp = CIImage(cgImage: img)
        var ciImage = temp;
        switch UIDevice.current.orientation {
        case .portrait:
            ciImage = temp.oriented(forExifOrientation: 6)
        case .landscapeRight:
            ciImage = temp.oriented(forExifOrientation: 3)
        case .landscapeLeft:
            ciImage = temp.oriented(forExifOrientation: 1)
        default:
            break
        }
        let viewcontroler = TestViewController(image: ciImage)
        viewcontroler.modalPresentationStyle = .formSheet
            self.present(viewcontroler, animated: true)
            
            
            let uiImage = UIImage(ciImage: ciImage)
            DispatchQueue.main.async {
                self.showHistogram(for: uiImage, channel: self.histogramChannel)
            }
        
    }

    func saveDNGToCameraRoll(_ dngData: Data) {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("captured.dng")
        do {
            try dngData.write(to: tempURL)

            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetCreationRequest.forAsset()
                        request.addResource(with: .photo, fileURL: tempURL, options: nil)
                    }) { success, error in
                        if let error {
                            print("Erro ao salvar a foto: \(error)")
                        } else {
                            print("Foto salva com sucesso!")
                        }
                    }
                } else {
                    print("Permissão para acessar a biblioteca de fotos negada.")
                }
            }
        } catch {
            print("Erro ao escrever o arquivo DNG: \(error)")
        }
    }
}

extension OSType {
    var rawFormatName:String {
        switch self {
        case 1815491698: return "lcri"
        case 1650943796: return "barw"
        default : return "Unknown"
        }
    }
}



struct FlashlightView: View {
    
    @State var flash: Bool = false
    var torchButtonPressed: () -> Void = { }
    
    var body: some View {
        Button {
            
            flash.toggle()
            self.torchButtonPressed()
        } label: {
            HStack {
                Image(systemName: flash ? "bolt.fill" : "bolt.slash.fill")
                    .contentTransition(.symbolEffect(.replace))
//                Image(systemName: "flashlight.\(flashState.flash ? "on" : "off").fill")
                Text(flash ? "On" : "Off")
                    .font(.title3)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(flash ? .yellow : .yellow.opacity(0.25))
    }
}


















/*
 Ecolher linha:
    - Vertical, horizontal ou diagonal
 Normalizar luminância
 solicitar em nanometros a escala
 Histograma - Comprimento de onda x quantidade de luz no comprimento
 */
