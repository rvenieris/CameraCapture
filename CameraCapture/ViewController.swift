//
//  ViewController2.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 30/09/24.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var photoOutput: AVCapturePhotoOutput!
    var displayLayer: AVSampleBufferDisplayLayer!

    var isImageFrozen = false // Para controlar o estado de congelamento da imagem

    var currentCameraIndex = 0
    var availableVideoDevices: [AVCaptureDevice] = []
    
    var currentCamera:AVCaptureDevice { availableVideoDevices[currentCameraIndex] }
    
    lazy var torchButton:UIButton = {
        let torchButton = UIButton(type: .system)
        torchButton.frame = CGRect(x: 20, y: 60, width: 100, height: 50)

        // Imagem e título para o estado normal (lanterna desligada)
        torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        torchButton.setTitle("Off", for: .normal)
        torchButton.setTitleColor(.gray, for: .normal)

        // Imagem e título para o estado selecionado (lanterna ligada)
        torchButton.setImage(UIImage(systemName: "flashlight.on.fill "), for: .selected)
        torchButton.setTitle(" On", for: .selected)
        torchButton.setTitleColor(.white, for: .selected)
        
        torchButton.contentHorizontalAlignment = .center
        torchButton.contentVerticalAlignment = .center
        torchButton.imageView?.contentMode = .scaleAspectFit

        torchButton.backgroundColor = .black.withAlphaComponent(0.5)
        torchButton.layer.cornerRadius = 10

        torchButton.addTarget(self, action: #selector(torchButtonPressed), for: .touchUpInside)
        return torchButton
    }()

    lazy var switchButton:UIButton = {
        let switchButton = UIButton(type: .system)
        switchButton.frame = CGRect(x: view.frame.width - 220, y: 60, width: 200, height: 50)
        switchButton.setTitle(currentCamera.localizedName, for: .normal)
        switchButton.setTitleColor(.white, for: .normal)
        
        switchButton.backgroundColor = .black.withAlphaComponent(0.5)
        switchButton.layer.cornerRadius = 10

        
        switchButton.addTarget(self, action: #selector(switchCameraButtonPressed), for: .touchUpInside)
        return switchButton
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


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDisplayLayer()
        
        view.addSubview(captureButton)
        view.addSubview(switchButton)
        if currentCamera.hasTorch { view.addSubview(torchButton) }
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo // Usamos .photo para permitir a captura RAW

        // Listar dispositivos de vídeo disponíveis
        availableVideoDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera],
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

    func setupDisplayLayer() {
        displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.frame = view.bounds
        view.layer.addSublayer(displayLayer)
    }

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

    @objc func switchCameraButtonPressed() {
        // Alternar para a próxima câmera
        currentCameraIndex = (currentCameraIndex + 1) % availableVideoDevices.count

        // Reconfigurar o dispositivo de entrada
        configureInputDevice()
        print(currentCamera.localizedName)
        switchButton.setTitle(currentCamera.localizedName, for: .normal)
    }
    
    @objc func torchButtonPressed() {
        do {
            try currentCamera.lockForConfiguration()
            currentCamera.torchMode = currentCamera.isTorchActive ? .off : .on
        } catch {
            print("lockForConfiguration Error: \(error)")
        }
        currentCamera.unlockForConfiguration()
        torchButton.isSelected.toggle()
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
//        connection.videoOrientation = .portrait
//        connection.videoRotationAngle = .pi / 2
        
        if !isImageFrozen {
            // Enfileirar o sampleBuffer para exibição
            displayLayer.sampleBufferRenderer.enqueue(sampleBuffer)
        }
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        if let error = error {
            print("Erro ao capturar foto: \(error)")
            return
        }

        guard let dngData = photo.fileDataRepresentation() else {
            print("Não foi possível obter os dados da foto.")
            return
        }

        // Salvar a foto em DNG no rolo da câmera
        saveDNGToCameraRoll(dngData)

        // Obter a imagem processada (JPEG) para gerar o histograma
        if let cgImage = photo.cgImageRepresentation() {
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.showHistogram(for: uiImage)
            }
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
                        if let error = error {
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


extension ViewController {

    func showHistogram(for image: UIImage) {
        // Calcular o histograma
        if let histogramData = calculateHistogram(for: image) {
            // Exibir o histograma
            let histogramView = HistogramView(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 200))
            histogramView.histogramData = histogramData
            histogramView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            view.addSubview(histogramView)
        }
    }

    func calculateHistogram(for image: UIImage) -> [Int]? {
        
        // Redimensionar a imagem para reduzir o número de pixels
        guard let resizedImage = image.resize(to: CGSize(width: 256, height: 256)) else { return nil }
        guard let cgImage = resizedImage.cgImage else { return nil }
//        guard let cgImage = image.cgImage else { return nil }

        // Criar bitmap context
        let width = cgImage.width
        let height = cgImage.height

        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let bitmapData = malloc(height * bytesPerRow) else { return nil }
        defer { free(bitmapData) }

        guard let context = CGContext(data: bitmapData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else { return nil }

        // Calcular o histograma
        var histogram = [Int](repeating: 0, count: 256)

        let pixelBuffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        for x in 0..<width {
            for y in 0..<height {
                let pixelIndex = (y * bytesPerRow) + (x * bytesPerPixel)

                let red = pixelBuffer[pixelIndex]
                let green = pixelBuffer[pixelIndex + 1]
                let blue = pixelBuffer[pixelIndex + 2]

                // Converter para luminância (escala de cinza)
                let luminance = 0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
                let index = min(255, max(0, Int(luminance)))
                histogram[index] += 1
            }
        }

        return histogram
    }
}

// View personalizada para desenhar o histograma
class HistogramView: UIView {

    var histogramData: [Int] = []

    override func draw(_ rect: CGRect) {
        guard !histogramData.isEmpty else { return }

        let maxCount = histogramData.max() ?? 1
        let width = rect.width / CGFloat(histogramData.count)

        let path = UIBezierPath()

        for (index, value) in histogramData.enumerated() {
            let x = CGFloat(index) * width
            let heightRatio = CGFloat(value) / CGFloat(maxCount)
            let y = rect.height * (1.0 - heightRatio)
            let barRect = CGRect(x: x, y: y, width: width, height: rect.height * heightRatio)
            path.append(UIBezierPath(rect: barRect))
        }

        UIColor.white.setFill()
        path.fill()
    }
}


// Extensão para redimensionar UIImage
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        return resized
    }
}
