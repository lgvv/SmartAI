# SmartAI

English | [한국어](README.ko.md)

An iOS app that judges banana freshness from a photo taken with the camera. An on-device CoreML model and a server-side CNN run the judgment at the same time, and if one side fails the other's result is still used.

<p align="center">
  <img src="./ResourceFiles/ConnectedServer.gif" width="32%" alt="Server connected state" />
  <img src="./ResourceFiles/UnConnectedServer.gif" width="32%" alt="Server disconnected state" />
</p>
<p align="center">
  <sub>Left: server connected · Right: server disconnected</sub>
</p>

---

## Background

| Item | Detail |
| --- | --- |
| Project | AI (CoreML, CNN) based fresh-food quality assessment program for a smart logistics system |
| Affiliation | Konkuk University, Dept. of Smart ICT Convergence Engineering |
| Award | Honorable Mention, 2022 KU SW Competition 🏆 |
| Duration | 2022.09 – 2022.11 (2 months) |
| Team | 3 members (iOS · Server · AI); this repository holds only the iOS client |
| Requirements | iOS 16.0+ · Swift 5 |

Quality inspection in fresh-food distribution still relies on manual labor. Different inspectors apply different standards, so results vary. This project solves that with a CNN-based classification model — take one photo and get a banana ripeness grade back.

Logistics sites tend to have unstable networks, so the judgment path is split into two.

| Path | Runs on | Model | Network |
| --- | --- | --- | --- |
| On-device | Device | CoreML image classifier (Create ML) | Not required |
| Server | Remote | CNN | Required |

Both paths run concurrently. If one fails, the other is unaffected. When the network is unreachable, the server request never even goes out, and the screen is completed using only the on-device result.

---

## Architecture

Layers are separated by folder and protocol ownership within a single target. Dependencies always point inward, toward Domain.

```text
Presentation ─┐
              ├──▶ Domain ◀── Data
Application ──┘   (Entity · Repository protocols · UseCase)
```

- `Domain`: Holds the app's business rules. Knows nothing about frameworks, with RxSwift as the sole exception.
- `Data`: Where Domain protocol implementations live. Alamofire, Vision, AVFoundation, and Network appear only here.
- `Presentation`: Views and Reactors built with ReactorKit. Screen transitions are owned by Coordinators.
- `Application`: The composition root — the only place that knows about all three layers.

```text
SmartAI/
├── Application/          AppDelegate · SceneDelegate · AppDependency
├── Domain/
│   ├── Entity/           BananaGrade · QualityAssessment · InferenceSource
│   │                     CapturedPhoto · ImageOrientation · error types
│   ├── Repository/       Quality assessment · camera · network reachability protocols
│   └── UseCase/          Assessment / camera session use cases and their default implementations
├── Data/
│   ├── Configuration/    ServerEnvironment
│   ├── DTO/              BananaResponseDTO
│   ├── DataSource/
│   │   ├── Camera/       AVFoundationPhotoCaptureSession
│   │   ├── Network/      Alamofire-based API client
│   │   └── Vision/       Vision-based image classifier
│   ├── Extension/        Two-way conversion between Domain types and CoreGraphics
│   └── Repository/       Domain protocol implementations
└── Presentation/
    ├── Common/           Coordinator
    ├── Camera/           Reactor · ViewController · PreviewView · Coordinator
    ├── Result/           Reactor · ViewController · Coordinator · SheetDetent
    └── Chart/            ChartView (SwiftUI) · Coordinator
```

### Screen flow

```text
AppCoordinator
   └─ CameraCoordinator ── capture ──▶ ResultCoordinator (presented as a sheet)
                                        └─ ChartCoordinator (pushed onto the sheet's internal stack)
```

Coordinators own screen transitions; delegates carry data between screens. The chart is pushed onto the navigation stack inside the result sheet, so `ResultCoordinator` also owns the transition into the chart — whoever holds the stack is responsible for what gets pushed onto it.

---

## Design decisions

Domain uses RxSwift. Every UseCase boundary type is either `Single` or `Completable`. Keeping them pure with closures or `async` would mean wrapping them back into Rx in Presentation, and that round trip wasn't worth it. In exchange, UIKit never enters Domain: `CapturedPhoto` carries `Data` and a domain `ImageOrientation` instead of a `UIImage`, and image decoding happens only in the Data layer.

The chart screen has no Reactor. Attaching `Action = Never` to a screen with no actions and no async state would be formality only, so `ChartView` and `ChartCoordinator` are all it needs.

DataSource protocols exist only where they're needed. `BananaQualityAPIClient` and `BananaImageClassifying` were introduced so repositories could be tested without a server or a model, respectively. `NWPathNetworkReachability` and `AVFoundationPhotoCaptureSession`, on the other hand, implement Domain protocols directly — there was no reason to stack an identical extra layer.

Business rules live in the use cases too. `DefaultRemoteQualityInspectionUseCase` decides network reachability, and `DefaultOnDeviceQualityInspectionUseCase` owns the rule that only the top four grades are shown. Both are tested without any screen.

---

## Concurrent assessment and race conditions

The result screen runs both assessments concurrently. If two callbacks push into the same array, neither ordering nor the result can be guaranteed. `ResultReactor` guards against this with three mechanisms.

```swift
case .viewDidLoad:
    return .merge(
        inspection(onDeviceInspection.execute(photo: photo)),
        inspection(remoteInspection.execute(photo: photo))
    )

private func inspection(_ source: Single<QualityAssessment>) -> Observable<Mutation> {
    source.asObservable()
        .map(Mutation.appendAssessment)
        .catch { .just(.setFailure(QualityInspectionError($0))) }
}

func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    mutation.observe(on: mutationScheduler)
}
```

1. A `catch` inside each stream isolates failures — if the server dies, the on-device result still survives.
2. `transform(mutation:)` funnels every mutation through a single scheduler, so `reduce` only ever runs one at a time.
3. `reduce` filters existing assessments by source (`InferenceSource`) before appending, so the same source arriving twice never duplicates.

`mutationScheduler` is injectable. Tests supply a `CurrentThreadScheduler` to verify state changes without waiting on asynchrony.

---

## Testing

A thin Given/When/Then layer sits on top of XCTest. Because it uses `XCTContext.runActivity`, the scenario itself shows up in the test report.

```swift
func test_한쪽_실패가_다른쪽_결과를_취소하지_않는다() {
    let (reactor, _, _) = given("the server fails while on-device succeeds") {
        makeSUT(onDevice: .just(onDeviceAssessment),
                remote: .error(QualityInspectionError.networkUnavailable))
    }

    when("the viewDidLoad action is sent") {
        reactor.action.onNext(.viewDidLoad)
    }

    then("the on-device assessment remains and the failure is delivered separately") {
        XCTAssertEqual(reactor.currentState.assessments, [onDeviceAssessment])
        XCTAssertEqual(reactor.currentState.failure, .networkUnavailable)
    }
}
```

All 38 tests run entirely in the simulator, with no server, camera, or CoreML involved. Screen appearance is pinned in code rather than with screenshots — tests check that there's exactly one capture button, that the font is Pretendard SemiBold 22pt, and that the button's bottom edge sits at 774pt at a fixed size.

```bash
xcodebuild -project SmartAI.xcodeproj -scheme SmartAI \
  -destination 'platform=iOS Simulator,name=iPhone 14 Pro' test
```

`ENABLE_TESTABILITY` is only enabled in Debug, so tests must run under the Debug configuration.

---

## Getting started

```bash
git clone <repository>
cd konkuk-capstone
open SmartAI.xcodeproj
```

Dependencies are fetched automatically by SPM — the project builds with no extra setup.

`SmartAI/Supporting Files/Configuration/Server.xcconfig` ships with a default server address. To point at a real server, create a `Server.local.xcconfig` in the same folder (it's gitignored).

```text
SERVER_BASE_URL = http:/$()/your-real-host:8000/predict
```

The `$()` breaks up `//` so it isn't read as an xcconfig comment. Because it's loaded with `#include?`, the build still succeeds even if the file is missing.

### Known constraints

- On-device inference only works on a real device. The Create ML sceneprint model can't create an inference context in the simulator, so Vision fails with `Code=9 "Could not create inference context"`. In the simulator this is handled as a `classificationUnsupported` error instead of a crash.
- The camera also requires a real device. The simulator has no capture device, so session configuration ends in `captureDeviceUnavailable`. Tapping the capture button doesn't crash — it flows into `sessionNotConfigured` instead.

---

## Tech stack

| Area | Used |
| --- | --- |
| UI | UIKit (code-based) · SnapKit · SwiftUI + Swift Charts |
| Architecture | Clean Architecture · ReactorKit · Coordinator · Delegate |
| Async | RxSwift · RxCocoa |
| ML | CoreML · Vision |
| Camera | AVFoundation |
| Network | Alamofire · Network (NWPathMonitor) |
| Testing | XCTest · RxTest · RxBlocking |

Dependency versions are pinned via `Package.resolved`: Alamofire 5.6.2 · ReactorKit 3.2.0 · RxSwift 6.5.0 · SnapKit 5.6.0.

---

## Author

Geonwoo Lee — full implementation of the iOS client
