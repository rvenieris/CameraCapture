//
//  ViewController+Captureaaa.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//

import UIKit

extension ViewController {
    

    func showHistogram(for image: UIImage, channel:HistogramChannel = .all) {
        // Calcular o histograma
        if let histogramData = calculateHistogram(for: image, channel: channel) {
            // Exibir o histograma
            let histogramView = HistogramView(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 200))
            histogramView.histogramData = histogramData
            histogramView.setColor(for: channel)
            histogramView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.addSubview(histogramView)
        }
    }

    func calculateHistogram(for image: UIImage, channel:HistogramChannel = .all, resolution: UInt = 256) -> [Int]? {
        
        // Redimensionar a imagem para reduzir o número de pixels
        guard let resizedImage = image.resize(to: CGSize(square: CGFloat(resolution))),
              let cgImage = resizedImage.cgImage else { return nil }
        
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
                let luminance = channel.redIndex * Double(red) + channel.greenIndex * Double(green) + channel.blueIndex * Double(blue)
                let index = min(255, max(0, Int(luminance)))
                histogram[index] += 1
            }
        }

        return histogram
    }
}
