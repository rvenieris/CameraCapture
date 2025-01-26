//
//  SliceAlignmentView.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//

import SwiftUI

struct SliceAlignmentView: View {
    
    @State var image: UIImage?
    @State var ciImage: CIImage?
    
    @State private var accumulatedRotationAngle = 0.0
    @State private var ongoingRotationAngle = 0.0
    var currentAngle: Double {
        @Wrapping(0.0..<180) var currentAngle = accumulatedRotationAngle + ongoingRotationAngle
        return currentAngle
    }
    
    @State var colors: [CIColor] = []
    
    var body: some View {
        VStack {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Color.blue
                }
            }
            .overlay {
                Rectangle()
                    .fill(.black)
                    .blendMode(.softLight)
                    .frame(width: 10, height: 2000)
                    .rotationEffect(.degrees(currentAngle - 90))
            }
            .clipped()
            .compositingGroup()
            .task {
                loadImage()
            }
            
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            footerControls
        }
        .gesture(lineRotationGesture)
        .sheet(isPresented: Binding(get: { !colors.isEmpty },
                                    set: { newColors in if !newColors { colors = [] } })) {
            CapturedLineViewController.swiftUI {
                CapturedLineViewController(capturedColors: colors)
            }
        }
    }
    
    private var lineRotationGesture: some Gesture {
        RotateGesture()
            .onChanged { value in
                ongoingRotationAngle = value.rotation.degrees
            }
            .onEnded { value in
                guard !ongoingRotationAngle.isNaN else { return }
                accumulatedRotationAngle += ongoingRotationAngle
                ongoingRotationAngle = 0
                guard !accumulatedRotationAngle.isNaN else {
                    accumulatedRotationAngle = 0
                    return
                }
            }
    }
    
    
    @ViewBuilder
    private var footerControls: some View {
        VStack {
            rotationSlider
            continueButton
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
    }
    @ViewBuilder
    private var rotationSlider: some View {
        HStack {
            Text(currentAngle.formatted(.number.precision(.fractionLength(0))) + "º")
                .monospacedDigit()
                .frame(minWidth: 50)
            
            Slider(value: Binding(get: { currentAngle },
                                  set: { accumulatedRotationAngle = $0 }), in: 0.0...180, step: 5) {
                Text(accumulatedRotationAngle.formatted(.number.precision(.fractionLength(0))))
            }
        }
    }
    
    
    @ViewBuilder
    private var continueButton: some View {
        Button {
            let angle = Angle.degrees(accumulatedRotationAngle).radians
            let capturedImage = rotateAndPreserveSize(ciImage!, by: angle, originalSize: ciImage!.extent.width)
            self.colors = capturedImage.centralLineColors()
        } label: {
            Label {
                Text("Slice")
            } icon: {
                Image(systemName: "arrowtriangle.right.fill.and.line.vertical.and.arrowtriangle.left.fill")
                    .rotationEffect(.degrees(currentAngle - 90))
            }
            .frame(minHeight: 32)
            .padding(.horizontal, 4)
        }
        .buttonStyle(.borderedProminent)
    }
    private func loadImage() {
        let ciImage = CIImage(forResource: "grid", withExtension: "jpeg")!
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        self.ciImage = ciImage
        self.image = UIImage(cgImage: cgImage).preparingThumbnail(of: CGSize(width: 500, height: 500))
    }
    
    private func rotateAndPreserveSize(_ image: CIImage, by radians: CGFloat, originalSize: CGFloat = 4032) -> CIImage {
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
}

#Preview {
    SliceAlignmentView(/*image: UIImage(ciImage: r!.outputImage!)*/)
}
