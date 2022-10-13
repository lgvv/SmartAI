enum CameraError: Error, Equatable {
    case captureDeviceUnavailable
    case captureInputRejected
    case captureOutputRejected
    case sessionNotConfigured
    case photoDataUnavailable
}
