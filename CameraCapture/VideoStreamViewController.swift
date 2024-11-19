//
//  ViewController.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 30/09/24.
//

import UIKit
import AVFoundation

class VideoStreamViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var displayLayer: AVSampleBufferDisplayLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDisplayLayer()
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd4K3840x2160 // Escolha a resolução desejada

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Não foi possível acessar a câmera.")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }

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

            captureSession.startRunning()

        } catch {
            print("Erro ao configurar a captura de vídeo: \(error)")
        }
    }
    
    func setupDisplayLayer() {
        displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.frame = view.bounds
        view.layer.addSublayer(displayLayer)
    }

}

extension VideoStreamViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Enfileirar o sampleBuffer para exibição
        displayLayer.sampleBufferRenderer.enqueue(sampleBuffer)
    }
}
