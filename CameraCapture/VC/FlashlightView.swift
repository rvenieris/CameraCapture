//
//  FlashlightView.swift
//  CameraCapture
//
//  Created by Victor Martins on 27/1/25.
//

import SwiftUI

struct FlashlightView: View {
    
    var torchButtonPressed: () -> Void = { }
    
    @State private var flash: Bool = false
    
    var body: some View {
        Button {
            self.flash.toggle()
            self.torchButtonPressed()
        } label: {
            HStack {
                Image(systemName: flash ? "bolt.fill" : "bolt.slash.fill")
                    .contentTransition(.symbolEffect(.replace))
                Text(flash ? "On" : "Off")
                    .font(.title3)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(flash ? .yellow : .yellow.opacity(0.25))
    }
}
