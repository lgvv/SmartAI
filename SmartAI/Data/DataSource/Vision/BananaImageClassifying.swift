import RxSwift

protocol BananaImageClassifying {
    func classify(photo: CapturedPhoto) -> Single<[BananaGrade]>
}
