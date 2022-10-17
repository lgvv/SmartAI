import Foundation
@testable import SmartAI

extension BananaGrade {
    static func fixture(name: String = "정상", probability: Float = 0.9) -> BananaGrade {
        BananaGrade(name: name, probability: probability)
    }
}

extension QualityAssessment {
    static func fixture(source: InferenceSource = .onDevice,
                        topGradeName: String = "정상",
                        grades: [BananaGrade] = [.fixture()]) -> QualityAssessment {
        QualityAssessment(source: source, topGradeName: topGradeName, grades: grades)
    }
}

extension CapturedPhoto {
    static func fixture(data: Data = Data([0xFF, 0xD8]), orientation: ImageOrientation = .up) -> CapturedPhoto {
        CapturedPhoto(data: data, orientation: orientation)
    }
}
