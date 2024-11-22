//
//  TestViewController.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 15/11/24.
//

import UIKit

class TestViewController: UIViewController {
    
    
    func newImageView(height:CGFloat? = nil) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                  width: view.bounds.width,
                                                  height: height ?? view.bounds.height))
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        return imageView
    }
    
    func solidView(color:UIColor)->UIView {
        let view = UIView(frame: view.frame)
        view.backgroundColor = color
        view.snapshotView(afterScreenUpdates: true)
        return view
    }
    
    /// <#Description#>
    /// - Parameter animated: True of false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Carregar e processar a imagem DNG
        guard let ciImage = CIImage(forResource: "Teste3", withExtension: "DNG") else {
            print("Falha ao carregar ou processar a imagem DNG.")
            return
        }
        
        let image = UIImage(ciImage: ciImage)
        
        let imageView = newImageView()
        view.addSubview(imageView)
        imageView.image = image
        
                
        let colors = ciImage.centralLineColors()
        let colorWall = colors.uiImageWall(height: view.bounds.height)
        
        let maxColors = colors.filter {$0.red == 1 || $0.green == 1 || $0.blue == 1 }
        print("Cores: \(maxColors.count)")
        maxColors.forEach {print($0.red, $0.green, $0.blue)}
        
        let imageView3 = newImageView(height: view.bounds.height / 1)
        imageView3.image = colorWall
        view.addSubview(imageView3)
        
        

    }


    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
