import RxSwift

final class DefaultOnDeviceBananaQualityRepository: OnDeviceBananaQualityRepository {
    private let classifier: BananaImageClassifying

    init(classifier: BananaImageClassifying) {
        self.classifier = classifier
    }

    func assess(photo: CapturedPhoto) -> Single<QualityAssessment> {
        classifier.classify(photo: photo)
            .map { grades in
                QualityAssessment(source: .onDevice,
                                  topGradeName: grades.first?.name ?? "",
                                  grades: grades)
            }
    }
}
