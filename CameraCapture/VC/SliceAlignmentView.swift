//
//  SliceAlignmentView.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//

import SwiftUI

struct SliceAlignmentView: View {
    @State var image: UIImage?
    
    @State var angle = 0.0
    @State var currentAngle = 0.0
    
    var body: some View {
        VStack {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
//                Color.red
            } else {
                Color.blue
            }
        }
        .task {
            let ciImage = CIImage(forResource: "Teste1", withExtension: "DNG")!
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
            image = UIImage(cgImage: cgImage).preparingThumbnail(of: CGSize(width: 500, height: 500))
//            let data = try! Data(contentsOf: Bundle.main.url(forResource: "Teste3", withExtension: "DNG")!)
////            let data = try! Data(contentsOf: url)
//            let filter =  CIRAWFilter(imageData: data, identifierHint: "DNG")
//            let ciImage = (filter?.outputImage)
////            let rep = NSCIImageRep(ciImage: ciImage!)
//            let nsImage = UIImage(ciImage: ciImage!)
////            nsImage.addRepresentation(ciImage)
//            image = nsImage// Image(uiImage: nsImage)
        }
        .overlay {
            Rectangle()
                .fill(.black)
                .blendMode(.softLight)
                .frame(width: 10, height: 2000)
                .rotationEffect(.degrees(angle + currentAngle))
        }
        .clipped()
        .compositingGroup()
            HStack {
                Text((angle + currentAngle).formatted(.number.precision(.fractionLength(0))) + "º")
                    .monospacedDigit()
                    .frame(minWidth: 50)
                Slider(value: Binding(get: {
                    return (angle + currentAngle).truncatingRemainder(dividingBy: 360)
                }, set: { v in
                    var v = v
                    while v < 0 { v += 360 }
                    while v >= 360 { v -= 360 }
                    angle = v
                }), in: 0.0...360.0) {
                    Text(angle.formatted(.number.precision(.fractionLength(0))))
                }
            }
            .padding(.horizontal)
        }
        .gesture(RotateGesture().onChanged({ v in
            currentAngle = v.rotation.degrees
            if angle + currentAngle < 0 { currentAngle += 360 }
            if angle + currentAngle >= 360 { currentAngle -= 360 }
        }).onEnded({ v in
            guard !currentAngle.isNaN else { return }
            angle += currentAngle
            while angle < 0 { angle += 360 }
            while angle >= 360 { angle -= 360 }
            currentAngle = 0
            guard !angle.isNaN else {
                print("nan")
                angle = 0
                return
            }
        }))
    }
}
import CoreImage

#Preview {
    //    let data = try! Data(contentsOf: Bundle.main.url(forResource: "Teste1", withExtension: "DNG")!)
    //    let r = CIRAWFilter(imageData: data)
    
    SliceAlignmentView(/*image: UIImage(ciImage: r!.outputImage!)*/)
}
