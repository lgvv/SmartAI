import UIKit
@testable import SmartAI

extension CapturedPhoto {
    static func generated(size: CGSize = CGSize(width: 300, height: 300)) -> CapturedPhoto {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor.yellow.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 40, y: 40,
                                                     width: size.width - 80,
                                                     height: size.height - 80))
        }

        return CapturedPhoto(data: image.jpegData(compressionQuality: 1.0) ?? Data(), orientation: .up)
    }
}
