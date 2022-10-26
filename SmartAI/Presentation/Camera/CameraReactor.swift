import ReactorKit
import RxSwift

final class CameraReactor: Reactor {
    enum Action {
        case viewDidLoad
        case viewWillDisappear
        case captureButtonTapped
    }

    enum Mutation {
        case setCapturing(Bool)
        case appendCapturedPhoto(CapturedPhoto)
        case setFailure(CameraError)
    }

    struct State {
        var isCapturing = false
        @Pulse var capturedPhoto: CapturedPhoto?
        @Pulse var failure: CameraError?
    }

    let initialState = State()

    private let cameraSession: CameraSessionUseCase

    init(cameraSession: CameraSessionUseCase) {
        self.cameraSession = cameraSession
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return cameraSession.start()
                .andThen(Observable<Mutation>.empty())
                .catch { .just(.setFailure(CameraError($0))) }

        case .viewWillDisappear:
            cameraSession.stop()
            return .empty()

        case .captureButtonTapped:
            guard !currentState.isCapturing else { return .empty() }

            return .concat(
                .just(.setCapturing(true)),
                cameraSession.capture()
                    .asObservable()
                    .map(Mutation.appendCapturedPhoto)
                    .catch { .just(.setFailure(CameraError($0))) },
                .just(.setCapturing(false))
            )
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setCapturing(isCapturing):
            state.isCapturing = isCapturing

        case let .appendCapturedPhoto(photo):
            state.capturedPhoto = photo

        case let .setFailure(error):
            state.failure = error
        }

        return state
    }
}
