//
//  SwiftUIViewControllerRepresentable.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//


import SwiftUI
import UIKit

struct SwiftUIViewControllerRepresentable<Content: ViewControllerTypeProtocol>: UIViewControllerRepresentable {
    typealias Configuration = (Content) -> Void
    
    var makeContent: () -> Content
    var configuration: Configuration?
    
    init(makeContent: @escaping () -> Content) {
        self.makeContent = makeContent
    }
    
    func makeUIViewController(context: Context) -> Content {
        makeContent()
    }
    
    func updateUIViewController(_ uiViewController: Content, context: Context) {
        configuration?(uiViewController)
    }
    
    func configure(_ configuration: @escaping Configuration) -> Self {
        var copy = self
        copy.configuration = configuration
        return copy
    }
}

extension ViewControllerTypeProtocol {
    static func swiftUI(makeView: @escaping () -> Self) -> SwiftUIViewControllerRepresentable<Self> {
        SwiftUIViewControllerRepresentable(makeContent: makeView)
    }
}
/// A protocol that all `UIView`s conform to, enabling extensions that have a `Self` reference.
protocol ViewControllerTypeProtocol: UIViewController {}
extension UIViewController: ViewControllerTypeProtocol {}
