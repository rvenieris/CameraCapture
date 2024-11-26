//
//  ViewExtensions.swift
//  CameraCapture
//
//  Created by Ricardo Almeida Venieris on 15/11/24.
//

import Foundation
import UIKit

// CIxxx
import CoreImage

/// Extensão da `CIImage` que fornece inicializadores convenientes e funções utilitárias.
extension CIImage {
    /// Cria uma instância de `CIImage` a partir de um recurso no bundle principal.
    ///
    /// Este inicializador procura pelo recurso especificado no bundle principal, tentando tanto a extensão em letras minúsculas quanto maiúsculas.
    /// Se o recurso for encontrado, inicializa uma `CIImage` com o conteúdo da URL.
    ///
    /// - Parameters:
    ///   - resource: O nome do arquivo de recurso.
    ///   - ext: A extensão do arquivo de recurso.
    ///
    /// - Returns: Uma instância opcional de `CIImage` se o recurso for encontrado e a inicialização for bem-sucedida; caso contrário, `nil`.
    ///
    /// - Note: Se a imagem contiver informações de orientação, elas não serão aplicadas (`applyOrientationProperty` é definido como `false`).
    convenience init?(forResource resource: String, withExtension ext: String) {
        guard let url = (Bundle.main.url(forResource: resource, withExtension: ext.lowercased()) ??
                         Bundle.main.url(forResource: resource, withExtension: ext.uppercased())) else {
            print("Não foi possível encontrar o arquivo .\(ext) chamado \(resource)")
            return nil
        }
        
        self.init(contentsOf: url, options: [CIImageOption.applyOrientationProperty: false])
    }
    
    /// Extrai as cores da linha central horizontal da imagem.
    ///
    /// Esta função renderiza uma faixa horizontal de 1 pixel de altura a partir do centro da imagem e lê a cor de cada pixel ao longo da largura da imagem.
    /// Ela retorna um array de objetos `CIColor` correspondentes a cada cor dos pixels.
    ///
    /// - Returns: Um array de `CIColor` representando as cores ao longo da linha central horizontal da imagem.
    ///
    /// - Note: Esta função assume que a imagem possui um espaço de cor associado. Se não houver, ela usa o espaço de cor Display P3 por padrão.
    func centralLineColors() -> [CIColor] {
        let ciImage = self
        var result: [CIColor] = []
        
        // Definir a região de interesse (ROI) como uma faixa de 1 pixel de altura no centro vertical da imagem.
        let roi = CGRect(x: ciImage.extent.minX,
                         y: ciImage.extent.midY,
                         width: ciImage.extent.width,
                         height: 1)
        
        // Definir o espaço de cor, usando Display P3 se não estiver disponível.
        let colorSpace = ciImage.colorSpace ?? CGColorSpace(name: CGColorSpace.displayP3) ?? CGColorSpaceCreateDeviceRGB()
        
        // Criar um CIContext com o espaço de cor apropriado.
        let ciContext = CIContext(options: [CIContextOption.outputColorSpace: colorSpace,
                                            CIContextOption.workingColorSpace: colorSpace])
        
        // Configurar o formato de pixel e alocação de memória.
        let bitmapFormat = CIFormat.RGBA8
        let bytesPerPixel = 4 // RGBA8 tem 4 bytes por pixel
        let bytesPerRow = bytesPerPixel * Int(roi.width)
        
        // Alocar memória para os dados dos pixels.
        guard let bitmapData = malloc(bytesPerRow) else {
            print("Sem memória suficiente")
            return []
        }
        defer {
            free(bitmapData)
        }
        
        // Renderizar a ROI no buffer de bitmap.
        ciContext.render(ciImage, toBitmap: bitmapData, rowBytes: bytesPerRow, bounds: roi, format: bitmapFormat, colorSpace: colorSpace)
        
        // Acessar os dados dos pixels.
        let pixelBuffer = bitmapData.bindMemory(to: UInt8.self, capacity: 4)
        
        // Iterar sobre cada pixel na ROI e extrair os componentes de cor.
        for x in 0..<Int(roi.width) {
            let offset = x * bytesPerPixel
            let red   = CGFloat(pixelBuffer[offset + 0]) / 255.0
            let green = CGFloat(pixelBuffer[offset + 1]) / 255.0
            let blue  = CGFloat(pixelBuffer[offset + 2]) / 255.0
            // let alpha = CGFloat(pixelBuffer[offset + 3]) / 255.0 // O canal alfa é ignorado
            
            // Criar um objeto CIColor a partir dos componentes extraídos.
            let ciColor = CIColor(red: red, green: green, blue: blue)
            result.append(ciColor)
        }
        return result
    }
}


extension CIColor {
    static func maxForEachComponent(_ lhs:CIColor, _ rhs: CIColor)->CIColor {
        let maxRed   = max(lhs.red, rhs.red)
        let maxGreen = max(lhs.green, rhs.green)
        let maxBlue  = max(lhs.blue, rhs.blue)
        return CIColor(red: maxRed, green: maxGreen, blue: maxBlue, alpha: 1)
    }
    
    static func / (lhs:CIColor, rhs: CIColor)->CIColor {
        let red   = lhs.red   / rhs.red
        let green = lhs.green / rhs.green
        let blue  = lhs.blue  / rhs.blue
        return CIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension [CIColor] {
    func uiImageWall(height: CGFloat = 100) -> UIImage? {
        let colors =  self
        let width = CGFloat(colors.count)
        let size = CGSize(width: width, height: height)
        
        // Iniciar um contexto gráfico com as dimensões especificadas
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // Iterar sobre cada cor e desenhar um retângulo vertical correspondente
        for (index, color) in colors.enumerated() {
            let x = CGFloat(index)
            let rect = CGRect(x: x, y: 0, width: 1, height: height)
            context.setFillColor(red: color.red, green: color.green, blue: color.blue, alpha: 1)
            context.fill(rect)
        }
        
        // Obter a imagem do contexto gráfico
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}



// UIxxx
extension UIImage {
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }

    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIColor {
    var ci: CIColor { return CIColor(color: self) }
}

extension [UIColor] {
    var ci: [CIColor] { return self.map {$0.ci} }
}






