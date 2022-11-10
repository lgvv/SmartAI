import UIKit

final class AppDependency {
    private let cameraSession = AVFoundationPhotoCaptureSession()
    private let onDeviceRepository = DefaultOnDeviceBananaQualityRepository(
        classifier: VisionBananaImageClassifier()
    )

    func makeCameraViewController() -> CameraViewController {
        let viewController = CameraViewController(previewView: CameraPreviewView(session: cameraSession.session))
        viewController.reactor = CameraReactor(
            cameraSession: DefaultCameraSessionUseCase(repository: cameraSession)
        )

        return viewController
    }

    func makeResultViewController(photo: CapturedPhoto) -> ResultViewController {
        let viewController = ResultViewController()
        viewController.reactor = ResultReactor(
            photo: photo,
            onDeviceInspection: DefaultOnDeviceQualityInspectionUseCase(repository: onDeviceRepository)
        )

        return viewController
    }
}
