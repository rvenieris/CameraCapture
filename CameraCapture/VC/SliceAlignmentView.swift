//
//  SliceAlignmentView.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//

import SwiftUI

struct SliceAlignmentView: View {
    
    var ciImage: CIImage
    @State private var image: UIImage?
    
    // Rotation Angle
    @State private var accumulatedRotationAngle = 0.0
    @State private var ongoingRotationAngle = 0.0
    var currentAngle: Double {
        @Wrapping(0.0..<180) var currentAngle = accumulatedRotationAngle + ongoingRotationAngle
        return currentAngle
    }
    @State private var isRotating = false
    
    // Debug Rotated Image
    @State private var showRotated = false
    @State private var rotated: UIImage?
    
    // Wall from Image Slice
    @State private var colors: [CIColor] = []
    @State private var wall: UIImage?
    @State private var wallSize: CGSize = .zero
    @State private var redMarker = 0.0
    @State private var blueMarker = 0.0
    
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                } else {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .overlay {
                Rectangle()
                    .fill(.gray)
                    .blendMode(.hardLight)
                    .frame(width: 10, height: 2000)
                    .rotationEffect(.degrees(currentAngle - 90))
            }
            .clipped()
            .compositingGroup()
            .task {
                loadImage()
                await refreshWall()
            }
            .task(id: currentAngle + ongoingRotationAngle) {
                await refreshWall()
            }
            
            
            if showRotated, let rotated {
                Image(uiImage: rotated)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        Rectangle()
                            .fill(.gray)
                            .blendMode(.hardLight)
                            .frame(width: 5, height: 2000)
                            .rotationEffect(.degrees(90))
                    }
                    .clipped()
            }
            wallComponent
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            footerControls
        }
        .gesture(lineRotationGesture)
        .task(id: currentAngle) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isRotating = true
            }
            let cancelled = (try? await Task.sleep(for: .seconds(0.5))) == nil
            guard !cancelled else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                isRotating = false
            }
        }
//        .sheet(isPresented: Binding(get: { !colors.isEmpty },
//                                    set: { newColors in if !newColors { colors = [] } })) {
//            CapturedLineViewController.swiftUI {
//                CapturedLineViewController(capturedColors: colors)
//            }
//        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Text("Continue")
                }
                .disabled(true)
            }
        }
    }
    
    @ViewBuilder
    private var wallComponent: some View {
        if let wall {
            Image(uiImage: wall)
                .resizable()
                .scaledToFit()
                .onGeometryChange(for: CGSize.self, of: \.size, action: { newValue in
                    wallSize = newValue
                    if redMarker == 0 {
                        redMarker = 0.25 * wallSize.width
                        blueMarker = 0.75 * wallSize.width
                    }
                })
                .overlay(alignment: .center) {
                    FrequencyMarkerView(
                        wallSize: wallSize,
                        markerPosition: $blueMarker,
                        isRotating: isRotating,
                        color: .blue
                    ) {
                        Text("400")
                        Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .overlay(alignment: .center) {
                    FrequencyMarkerView(
                        wallSize: wallSize,
                        markerPosition: $redMarker,
                        isRotating: isRotating,
                        color: .red
                    ) {
                        Text("700")
                        Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .animation(.snappy(duration: 0.1), value: redMarker)
                .animation(.snappy(duration: 0.1), value: blueMarker)
        }
    }
    
    // MARK: Rotation Gesture
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
    
    
    // MARK: - Components
    
    @ViewBuilder
    private var footerControls: some View {
        VStack {
            rotationSlider
//            continueButton
//                .frame(maxWidth: .infinity, alignment: .trailing)
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
            Task { await self.refreshWall() }
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
    
    
    // MARK: - Actions
    
    private func loadImage() {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        self.image = UIImage(cgImage: cgImage).preparingThumbnail(of: CGSize(width: 500, height: 500))
    }
    
    nonisolated private func refreshWall() async {
        let angle = await Angle.degrees(accumulatedRotationAngle).radians
        guard !Task.isCancelled else { return }
        
        let capturedImage = await ciImage.rotateAndPreserveSize(by: angle, originalSize: ciImage.extent.width)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(capturedImage, from: capturedImage.extent)!
        guard !Task.isCancelled else { return }
        
        let centralColors = capturedImage.centralLineColors()
        let rotated = UIImage(cgImage: cgImage)
        guard !Task.isCancelled else { return }
        
        let wall = centralColors.uiImageWall2(mul: 0.75)
        await MainActor.run {
            self.colors = centralColors
            self.rotated = rotated
            if let wall { self.wall = wall }
        }
    }
}
#Preview {
    SliceAlignmentView(ciImage: CIImage(forResource: "Teste3", withExtension: "DNG")!)
}

extension CIImage {
    func rotateAndPreserveSize(by radians: CGFloat, originalSize: CGFloat = 4032) -> CIImage {
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
        return self.transformed(by: combinedTransform)
    }
}




struct FrequencyMarkerView<Label: View>: View {
    
    var wallSize: CGSize
    @Binding var markerPosition: Double
    var isRotating: Bool
    var color: Color
    @ViewBuilder var label: () -> Label
    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 3, height: wallSize.height/1.5)
            .blendMode(.difference)
            .overlay {
                VStack {
                    label()
                }
                .monospaced()
                .fixedSize(horizontal: true, vertical: false)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                }
            }
            .position(x: markerPosition)
            .gesture(DragGesture().onChanged({ v in
                markerPosition = v.location.x
            }))
            .offset(y: wallSize.height/2)
            .opacity(!isRotating ? 1 : 0)
        //                            .animation(.default, value: isRotating)
    }
}


