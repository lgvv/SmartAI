enum CameraError: Error, Equatable {
    case captureDeviceUnavailable
    case captureInputRejected
    case captureOutputRejected
    case sessionNotConfigured
    case photoDataUnavailable
    case unknown

    init(_ error: Error) {
        self = (error as? CameraError) ?? .unknown
    }
}
