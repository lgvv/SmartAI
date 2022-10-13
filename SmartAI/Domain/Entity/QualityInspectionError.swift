enum QualityInspectionError: Error, Equatable {
    case networkUnavailable
    case serverRequestFailed(reason: String)
    case classificationModelUnavailable
    case classificationUnsupported
    case classificationEmpty
    case undecodablePhoto
}
