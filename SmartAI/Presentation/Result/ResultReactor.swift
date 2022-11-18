import ReactorKit
import RxSwift

final class ResultReactor: Reactor {
    enum Action {
        case viewDidLoad
        case detentChanged(SheetDetent)
        case moreInfoButtonTapped
    }

    enum Mutation {
        case appendAssessment(QualityAssessment)
        case setFailure(QualityInspectionError)
        case setMoreInfoVisible(Bool)
        case requestChart([QualityAssessment])
    }

    struct State {
        let photo: CapturedPhoto
        var assessments: [QualityAssessment] = []
        var topGradeName = ""
        var isMoreInfoVisible = false
        @Pulse var chartRequest: [QualityAssessment]?
        @Pulse var failure: QualityInspectionError?
    }

    let initialState: State

    private let onDeviceInspection: OnDeviceQualityInspectionUseCase
    private let remoteInspection: RemoteQualityInspectionUseCase
    private let mutationScheduler: ImmediateSchedulerType

    init(photo: CapturedPhoto,
         onDeviceInspection: OnDeviceQualityInspectionUseCase,
         remoteInspection: RemoteQualityInspectionUseCase,
         mutationScheduler: ImmediateSchedulerType = MainScheduler.asyncInstance) {
        self.initialState = State(photo: photo)
        self.onDeviceInspection = onDeviceInspection
        self.remoteInspection = remoteInspection
        self.mutationScheduler = mutationScheduler
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let photo = currentState.photo

            return .merge(
                inspection(onDeviceInspection.execute(photo: photo)),
                inspection(remoteInspection.execute(photo: photo))
            )

        case let .detentChanged(detent):
            return .just(.setMoreInfoVisible(detent == .large))

        case .moreInfoButtonTapped:
            return .just(.requestChart(currentState.assessments))
        }
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        mutation.observe(on: mutationScheduler)
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .appendAssessment(assessment):
            state.assessments = state.assessments.filter { $0.source != assessment.source } + [assessment]
            state.topGradeName = assessment.topGradeName

        case let .setFailure(error):
            state.failure = error

        case let .setMoreInfoVisible(isVisible):
            state.isMoreInfoVisible = isVisible

        case let .requestChart(assessments):
            state.chartRequest = assessments
        }

        return state
    }

    private func inspection(_ source: Single<QualityAssessment>) -> Observable<Mutation> {
        source
            .asObservable()
            .map(Mutation.appendAssessment)
            .catch { .just(.setFailure(QualityInspectionError($0))) }
    }
}
