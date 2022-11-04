import CoreImage
import CoreML
import RxSwift
import Vision

final class VisionBananaImageClassifier: BananaImageClassifying {
    private let model: VNCoreMLModel?

    init() {
        model = try? VNCoreMLModel(for: BananaClassification(configuration: MLModelConfiguration()).model)
    }

    func classify(photo: CapturedPhoto) -> Single<[BananaGrade]> {
        Single.create { [self] observer in
            guard let model = self.model else {
                observer(.failure(QualityInspectionError.classificationModelUnavailable))
                return Disposables.create()
            }

            guard let image = CIImage(data: photo.data) else {
                observer(.failure(QualityInspectionError.undecodablePhoto))
                return Disposables.create()
            }

            let request = VNCoreMLRequest(model: model) { request, _ in
                guard let observations = request.results as? [VNClassificationObservation] else {
                    observer(.failure(QualityInspectionError.classificationUnsupported))
                    return
                }

                guard !observations.isEmpty else {
                    observer(.failure(QualityInspectionError.classificationEmpty))
                    return
                }

                observer(.success(observations.map {
                    BananaGrade(name: $0.identifier, probability: $0.confidence)
                }))
            }
            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(ciImage: image,
                                                orientation: CGImagePropertyOrientation(photo.orientation))
            do {
                try handler.perform([request])
            } catch {
                observer(.failure(QualityInspectionError.classificationUnsupported))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
}
