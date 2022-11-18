import UIKit

final class AppDependency {
    private let cameraSession = AVFoundationPhotoCaptureSession()
    private let reachability = NWPathNetworkReachability()

    private let onDeviceRepository = DefaultOnDeviceBananaQualityRepository(
        classifier: VisionBananaImageClassifier()
    )

    private lazy var remoteRepository: RemoteBananaQualityRepository = {
        guard let environment = try? ServerEnvironment() else {
            return MisconfiguredRemoteBananaQualityRepository()
        }

        return DefaultRemoteBananaQualityRepository(
            apiClient: AlamofireBananaQualityAPIClient(baseURL: environment.baseURL)
        )
    }()

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
            onDeviceInspection: DefaultOnDeviceQualityInspectionUseCase(repository: onDeviceRepository),
            remoteInspection: DefaultRemoteQualityInspectionUseCase(repository: remoteRepository,
                                                                   reachability: reachability)
        )

        return viewController
    }
}
