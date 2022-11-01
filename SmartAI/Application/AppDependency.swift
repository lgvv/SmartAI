import UIKit

final class AppDependency {
    private let cameraSession = AVFoundationPhotoCaptureSession()

    func makeCameraViewController() -> CameraViewController {
        let useCase = DefaultCameraSessionUseCase(repository: cameraSession)
        let viewController = CameraViewController(previewView: CameraPreviewView(session: cameraSession.session))
        viewController.reactor = CameraReactor(cameraSession: useCase)

        return viewController
    }
}
