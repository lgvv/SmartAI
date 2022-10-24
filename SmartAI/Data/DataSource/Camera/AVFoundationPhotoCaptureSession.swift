import AVFoundation
import AudioToolbox
import RxSwift
import UIKit

final class AVFoundationPhotoCaptureSession: NSObject {
    private static let shutterSoundIdentifier: SystemSoundID = 1108

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.smartai.camera.session", qos: .userInitiated)
    private let photoOutput = AVCapturePhotoOutput()
    private let captureResult = PublishSubject<Result<CapturedPhoto, CameraError>>()
    private var isConfigured = false

    private func configureIfNeeded() throws {
        guard !isConfigured else { return }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video) else {
            throw CameraError.captureDeviceUnavailable
        }

        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            throw CameraError.captureInputRejected
        }

        guard session.canAddInput(input) else { throw CameraError.captureInputRejected }
        session.addInput(input)

        guard session.canAddOutput(photoOutput) else { throw CameraError.captureOutputRejected }
        session.addOutput(photoOutput)

        isConfigured = true
    }
}

extension AVFoundationPhotoCaptureSession: CameraRepository {
    func startSession() -> Completable {
        Completable.create { [weak self] observer in
            guard let self else {
                observer(.completed)
                return Disposables.create()
            }

            self.sessionQueue.async {
                do {
                    try self.configureIfNeeded()
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                    observer(.completed)
                } catch {
                    observer(.error(error))
                }
            }

            return Disposables.create()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func capturePhoto() -> Single<CapturedPhoto> {
        Single.create { [weak self] observer in
            guard let self else { return Disposables.create() }

            let subscription = self.captureResult
                .take(1)
                .subscribe(onNext: { result in
                    switch result {
                    case let .success(photo): observer(.success(photo))
                    case let .failure(error): observer(.failure(error))
                    }
                })

            self.sessionQueue.async {
                guard self.isConfigured else {
                    self.captureResult.onNext(.failure(.sessionNotConfigured))
                    return
                }

                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }

            return subscription
        }
    }
}

extension AVFoundationPhotoCaptureSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(Self.shutterSoundIdentifier)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(Self.shutterSoundIdentifier)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            captureResult.onNext(.failure(.photoDataUnavailable))
            return
        }

        captureResult.onNext(.success(CapturedPhoto(data: data,
                                                    orientation: ImageOrientation(image.imageOrientation))))
    }
}
