import RxSwift

struct MisconfiguredRemoteBananaQualityRepository: RemoteBananaQualityRepository {
    func assess(photo: CapturedPhoto) -> Single<QualityAssessment> {
        .error(QualityInspectionError.serverRequestFailed(reason: "서버 주소가 설정되지 않았습니다"))
    }
}
