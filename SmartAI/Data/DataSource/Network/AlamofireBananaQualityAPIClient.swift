import Alamofire
import Foundation
import RxSwift

final class AlamofireBananaQualityAPIClient: BananaQualityAPIClient {
    private static let imageFieldName = "request_img"
    private static let imageMimeType = "image/jpg"
    private static let headers: HTTPHeaders = ["Content-Type": "multipart/form-data"]

    private let baseURL: URL
    private let session: Session

    init(baseURL: URL, session: Session = .default) {
        self.baseURL = baseURL
        self.session = session
    }

    func uploadPhoto(_ photo: CapturedPhoto) -> Single<BananaResponseDTO> {
        Single.create { [baseURL, session] observer in
            let request = session.upload(multipartFormData: { formData in
                formData.append(photo.data,
                                withName: Self.imageFieldName,
                                fileName: "\(UUID().uuidString).jpg",
                                mimeType: Self.imageMimeType)
            }, to: baseURL, method: .post, headers: Self.headers)
                .validate()
                .responseDecodable(of: BananaResponseDTO.self) { response in
                    switch response.result {
                    case let .success(dto):
                        observer(.success(dto))
                    case let .failure(error):
                        observer(.failure(QualityInspectionError.serverRequestFailed(
                            reason: error.localizedDescription
                        )))
                    }
                }

            return Disposables.create { request.cancel() }
        }
    }
}
