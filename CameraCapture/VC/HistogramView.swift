//
//  HistogramView.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//

import UIKit

// View personalizada para desenhar o histograma
class HistogramView: UIView {

    var histogramData: [Int] = []
    var color: UIColor = .white

    override func draw(_ rect: CGRect) {
        addTapGesture()

        guard !histogramData.isEmpty else { return }

        let maxCount = histogramData.max() ?? 1
        let width = rect.width / CGFloat(Array(histogramData.enumerated()).last(where: {$0.element > 0 })?.offset ?? histogramData.count)

        let path = UIBezierPath()

        for (index, value) in histogramData.enumerated() {
            let x = CGFloat(index) * width
            let heightRatio = CGFloat(value) / CGFloat(maxCount)
            let y = rect.height * (1.0 - heightRatio)
            let barRect = CGRect(x: x, y: y, width: width, height: rect.height * heightRatio)
            path.append(UIBezierPath(rect: barRect))
        }

        color.setFill()
        path.fill()
    }
    
    func addTapGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeFromSuperview))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setColor(for channel:HistogramChannel) {
        switch channel {
        case .red:
            color = .red
        case .green:
            color = .green
        case .blue:
            color = .blue
        case .all:
            color = .white
        }
    }
}
