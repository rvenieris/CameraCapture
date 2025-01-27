//
//  MainCameraControls.swift
//  CameraCapture
//
//  Created by Victor Martins on 27/1/25.
//

import SwiftUI

struct MainCameraControls: View {
    
    var capture: () -> Void = { }
    var histogramChannelSelected: (HistogramChannel) -> Void = { _ in }
    var nextStep: () -> Void = { }
    
    @State private var histogramChannel: HistogramChannel = .all
    @State private var captured: Bool = false
    
    var body: some View {
        ZStack {
            Button {
                self.captured.toggle()
                self.capture()
            } label: {
                Circle()
                    .fill(captured ? .gray : .white)
                    .frame(width: 55, height: 55)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                    }
            }
            .padding(5)
            .background {
                Circle()
                    .stroke(.white, lineWidth: 5)
            }
            .frame(maxWidth: .infinity)
            
            if captured {
                HStack {
                    channelPicker
                    
                    Spacer()
                    
                    Button {
                        nextStep()
                    } label: {
                        Label("Continue", systemImage: "distribute.horizontal.center.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var channelPicker: some View {
        Picker("H", selection: $histogramChannel) {
            Text("R")
                .foregroundStyle(.red)
                .tag(HistogramChannel.red)
            Text("G")
                .foregroundStyle(.green)
                .tag(HistogramChannel.green)
            Text("B")
                .foregroundStyle(.blue)
                .tag(HistogramChannel.blue)
            Text("All")
                .tag(HistogramChannel.all)
        }
        .pickerStyle(.segmented)
        .fixedSize()
        .background(.background, in: .rect(cornerRadius: 8))
        .font(.subheadline)
        .onChange(of: histogramChannel) {
            self.histogramChannelSelected(histogramChannel)
        }
    }
}

#Preview {
    MainCameraControls()
}
