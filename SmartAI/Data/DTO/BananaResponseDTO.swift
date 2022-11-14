import Foundation

struct BananaResponseDTO: Decodable {
    let imgName: String
    let bananaClasses: [Int: String]
    let probability: [Int: Float]
    let argmax: Int

    enum CodingKeys: String, CodingKey {
        case imgName = "img_name"
        case bananaClasses = "banana_classes"
        case probability = "Probability"
        case argmax
    }
}

extension BananaResponseDTO {
    func toDomain() -> QualityAssessment {
        let grades = bananaClasses.keys.sorted().compactMap { key -> BananaGrade? in
            guard let name = bananaClasses[key], let probability = probability[key] else { return nil }

            return BananaGrade(name: name, probability: probability)
        }

        return QualityAssessment(source: .server,
                                 topGradeName: bananaClasses[argmax] ?? "",
                                 grades: grades)
    }
}
